class StaticPagesController < ApplicationController
  def about
    @release_note = ''
    r_notes = TcReleaseNote.all.order(updated_at: :desc)
    return if r_notes.blank?

    r_notes.each do |r_note|
      @release_note << "#{r_note.release}<br/>"
      comment = JSON.parse r_note.notes
      comment['data'].each_with_index do |c, index|
        @release_note << "#{index + 1}. #{c}<br/>"
      end
      @release_note << '<br/>'
    end
  end
end
