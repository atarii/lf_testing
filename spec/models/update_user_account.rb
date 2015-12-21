require 'spec_helper'

class UserUnitTest
  describe 'Update User Account' do
    # Set variable
    first_name = 'ltrc'
    last_name = 'vn'
    email = 'ltrc_test@leapfrog.test'
    password = '123456'
    first_name_updated = 'ltrc_updated'
    last_name_updated = 'ltrc_updated'
    email_updated = 'ltrc_qa_updated_test@leapfrog.test'
    password_updated = '135246DN'
    user_id = nil
    acc_info = nil

    context 'Pre-condition - create user' do
      before :all do
        User.new.do_create_user(first_name, last_name, email, password, 1, 3)
        acc_info = User.new.get_user_info(email)
        user_id = acc_info[:id]
      end

      it 'Verify that account is added to DB successfully' do
        expect(user_id).to_not eq(nil)
      end

      it 'Verify user information in UserRoleMap table' do
        expect(acc_info[:role_id]).to eq(3)
      end
    end

    context 'TC01 - Test update email' do
      it 'Update email user' do
        User.new.do_update_user(user_id, password, first_name, last_name, email_updated, 1, 3)
        expect(User.get_user_info_by_id(user_id)[:email]).to eq(email_updated)
      end
    end

    context 'TC02 - Test update first_name' do
      it 'Update first_name user' do
        User.new.do_update_user(user_id, password, first_name_updated, last_name, email_updated, 1, 3)
        expect(User.get_user_info_by_id(user_id)[:first_name]).to eq(first_name_updated)
      end
    end

    context 'TC03 - Test update last_name' do
      it 'Update last_name user' do
        User.new.do_update_user(user_id, password, first_name_updated, last_name_updated, email_updated, 1, 3)
        expect(User.get_user_info_by_id(user_id)[:last_name]).to eq(last_name_updated)
      end
    end

    context 'TC04 - Test update password' do
      it 'Update password user' do
        pass_before = User.find(user_id).password
        User.new.do_update_user(user_id, password_updated, first_name_updated, last_name_updated, email_updated, 1, 3)
        expect(User.get_user_info_by_id(user_id)[:password]).to_not eq(pass_before)
      end
    end

    context 'TC 05 - Test update role' do
      it 'Update role from QA to Power' do
        User.new.do_update_user(user_id, password_updated, first_name_updated, last_name_updated, email_updated, 1, 2)
        expect(UserRoleMap.find_by(user_id: user_id).role_id).to eq(2)
      end

      it 'Update role from Power to Admin' do
        User.new.do_update_user(user_id, password_updated, first_name_updated, last_name_updated, email_updated, 1, 1)
        expect(UserRoleMap.find_by(user_id: user_id).role_id).to eq(1)
      end

      it 'Update role from Admin to QA' do
        User.new.do_update_user(user_id, password_updated, first_name_updated, last_name_updated, email_updated, 1, 3)
        expect(UserRoleMap.find_by(user_id: user_id).role_id).to eq(3)
      end
    end

    context 'TC06 - Test update active' do
      it 'Update from actived to none-active' do
        User.new.do_update_user(user_id, password_updated, first_name_updated, last_name_updated, email_updated, 0, 3)
        expect(User.get_user_info_by_id(user_id)[:is_active]).to eq(false)
      end

      it 'Update from none-active to actived' do
        User.new.do_update_user(user_id, password_updated, first_name_updated, last_name_updated, email_updated, 1, 3)
        expect(User.get_user_info_by_id(user_id)[:is_active]).to eq(true)
      end
    end

    context 'TC07 - Test update mix fields' do
      it 'Update mix fields' do
        User.new.do_update_user(user_id, password, first_name, last_name, email, 1, 3)
        expect(User.get_user_info_by_id(user_id)).to eq(id: user_id,
                                                            first_name: first_name,
                                                            last_name: last_name,
                                                            email: email,
                                                            is_active: true,
                                                            full_name: "#{first_name} #{last_name}")
      end
    end

    after :all do
      User.find(user_id).destroy
      UserRoleMap.find_by(user_id: user_id).destroy
    end
  end
end
