require 'mysql'
require 'nokogiri'

class ImportSoapToDb
  ENGLISH_COUNTRY = ['US_APPCENTER', 'UK_APPCENTER', 'CA_APPCENTER', 'AU_APPCENTER', 'IE_APPCENTER', 'ROW_APPCENTER']
  FRENCH_COUNTRY = ['FR_FR_APPCENTER', 'FR_CA_APPCENTER', 'FR_ROW_APPCENTER']

  #
  # import data for english
  #
  def import_data_for_english(con, table)
    ENGLISH_COUNTRY.each { |country|
      execute(con, table, country)
    }
  end

  #
  # import data for french
  #
  def import_data_for_french(con, table)
    FRENCH_COUNTRY.each { |country|
      execute(con, table, country)
    }
  end

  private
  #
  # call webservice and then insert data to database
  # argument: country, for example: US_APPCENTER
  #
  def execute(con, table, country)
    offset = 0
    total_results = nil
    begin
      res_xml = get_product_feed(country, offset)
      if total_results.nil?
        total_results = res_xml.at_xpath('//Paging/TotalResults').text.to_i
      end
      import(con, table, res_xml)
      offset = offset + 100
    end while offset<=total_results
  end

  #
  # sending get_product_feed request
  #
  def get_product_feed(country, offset)
    CommonMethods.soap_call(
      'http://emqlacws.leapfrog.com:8080/webservices/productfeedwebservice',
      'http://services.leapfrog.com/webservices/productfeedwebservice',
      :get_product_feed,
      "<GetProductFeedRequest>
        <Country>#{country}</Country>
        <Paging>
          <Offset>#{offset}</Offset><MaxResults>100</MaxResults>
        </Paging>
      </GetProductFeedRequest>"
    )
  end

  # Get node values
  # @xpath: the xml path to an element
  # @return: array of values
  def getNodeValues(xml, xpath)
    lst = []
    items = xml.xpath(xpath)
    items.map {
      |e| lst.push [e.text]
    }
    return items
  end

  #
  # extract data from xml text and insert to database
  #
  def import con, table, xml
    # Get all node in xml file that contains product information
    temp = getNodeValues(xml, '*//Products/Product')

    # Prepair data for fields that will add to database
    if !temp.nil? and temp.count > 0
      temp.each do |item|
        $catalog = item.at_xpath('Catalog').text
        if item.xpath('Price/Currency').text == 'USD'
          $price = '$' + '%0.2f' % item.xpath('Price/PriceTier/ListPrice').text.to_f
        else
          $price = ''
        end
        $appstatus = 'unknown'
        $sku = item.at_xpath('SkuCode').text
        $shorttitle = item.at_xpath('Name').text
        $platformcompatibility = ''
        $lpu = ''
        $lp2 = ''
        $lp1 = ''
        $lgs = ''
        $lex = ''
        $lpr = ''
        # --Process locale
        $us = ''
        $ca = ''
        $uk = ''
        $ie = ''
        $au = ''
        $row = ''
        $fr_fr = ''
        $fr_ca = ''
        $fr_row = ''
        $character = ''
        if $catalog.include? 'US_'
          $us = 'X'
        end
        if $catalog.include? 'UK_'
          $uk = 'X'
        end
        if $catalog.include? 'IE_'
          $ie = 'X'
        end
        if $catalog.include? 'AU_'
          $au = 'X'
        end
        if $catalog.include? 'ROW_'
          $row = 'X'
        end
        if $catalog.include? 'FR_FR_'
          $fr_fr = 'X'
        end
        if $catalog.include? 'FR_CA_'
          $fr_ca = 'X'
        else
          if $catalog.include? 'CA_'
            $ca = 'X'
          end
        end
        if $catalog.include? 'FR_ROW_'
          $fr_row = 'X'
        end
        # --End Process locale

        item.at_xpath('Attributes').elements.to_a.each do |i| # begin each child
          case i.attributes['Key'].text
            # Go live date maps with release date in database
          when "releaseDate"
            $golivedate = i.at_xpath('Values').text

            # long name maps with longtitle in database
          when "longName_en", "longName_fr"
            $longtitle = i.at_xpath('Values').text

            # Gender maps with gender in database
          when "gender_en", "gender_fr"
            genderflag = 0
            i.elements.to_a.each do |m|
              if m.name == 'Values'
                $gender = m.text.capitalize
                genderflag += 1
              end
              if genderflag == 2
                $gender = 'All'
              end
            end

            # Age Range Begin maps with agefrommonths in database
          when "ageRangeBegin"
            $agefrommonths = i.at_xpath('Values').text

            # Age Range End maps with agefrommonths in database
          when "ageRangeEnd"
            $agetomonths = i.at_xpath('Values').text

            # Skill maps with skill in database
          when "skill_en", "skill_fr"
            $skill = i.at_xpath('Values').text

            # curriculum maps with curriculum in database
          when "curriculum_en", "curriculum_fr"
            $curriculum = i.at_xpath('Values').text

            # Long Description maps with longdesc in database
          when "longDescription_en", "longDescription_fr"
            $longdesc = i.at_xpath('Values').text.gsub("\"", "\\\"")

            # credits will map later
            $credits = 'unknown'

            #---------platformcompatibility process
            # worksWithLeapPad2_en maps with platformcompatibility in database
          when "worksWithLeapPad2_en", "worksWithLeapPad2_fr"
            if i.at_xpath('Values').text == "true"
              $platformcompatibility += "LeapPad 2,\n"
              $lp2 = 'X'
            end
            # worksWithLeapPad_en maps with platformcompatibility in database
          when "worksWithLeapPad_en", "worksWithLeapPad_fr"
            if i.at_xpath('Values').text == "true"
              $platformcompatibility += "LeapPad Explorer,\n"
              $lp1 = 'X'
            end
            # worksWithLeapPadUltra_en maps with platformcompatibility in database
          when "worksWithLeapPadUltra_en", "worksWithLeapPadUltra_fr"
            if i.at_xpath('Values').text == "true"
              $platformcompatibility += "LeapPad Ultra,\n"
              $lpu = 'X'
            end
            # worksWithLeapster_en maps with platformcompatibility in database
          when "worksWithLeapster_en", "worksWithLeapster_fr"
            if i.at_xpath('Values').text == "true"
              $platformcompatibility += "Leapster Explorer,\n"
              $lex = 'X'
            end
            # worksWithLeapsterGS_en maps with platformcompatibility in database
          when "worksWithLeapsterGS_en", "worksWithLeapsterGS_fr"
            if i.at_xpath('Values').text == "true"
              $platformcompatibility += "LeapsterGS Explorer,\n"
              $lgs = 'X'
            end
            # worksWithLeapReader_en maps with platformcompatibility in database
          when "worksWithLeapReader_en", "worksWithLeapReader_fr"
            if i.at_xpath('Values').text == "true"
              $platformcompatibility += "Leapreader,\n"
              $lpr = 'X'
            end
            #---------End platformcompatibility process

            # Special Message maps with speacialmsg in database
          when "specialMessage_en", "specialMessage_fr"
            if i.at_xpath('Values') != nil
              $specialmsg = i.at_xpath('Values').text
            end

            # Teaches maps with teaches in database
          when "teaches_en", "teaches_fr"
            $teaches = i.at_xpath('Values').text

            # License legal will be added later
            $licenselegal = 'unknown'

            # licensedContent will be added later
            $licnonlic = 'unknown'

            # License will be added later
            $license = 'unknown'

            # language will be added later
            $language = 'unknown'

            # Pricetier maps with pricetier"
          when "pricingTier"
            $pricetier = i.at_xpath('Values').text + ' - ' + $price

            # contentType maps with category
          when "contentType"
            $category = i.at_xpath('Values').text

            # character maps with character
          when "character"
            i.elements.to_a.each do |m|
              if m.name=='Values'
                $character << ',' unless $character == ''
                $character << m.text
              end #if
            end # each

          end # end case
        end # end each child

        # Excute query to add data to database
        # -- Begin Process if sku has ready existed
        rowsku = con.query "SELECT sku,us,ca,uk,ie,au,row,fr_fr,fr_ca,fr_row from #{table}"
        skuexisted = 0
        rowsku.each_hash do |rs|
          if $sku == rs['sku']
            if rs['us'].downcase == 'x'
              $us = 'X'
            end
            if rs['ca'].downcase == 'x'
              $ca = 'X'
            end
            if rs['uk'].downcase == 'x'
              $uk = 'X'
            end
            if rs['ie'].downcase == 'x'
              $ie = 'X'
            end
            if rs['au'].downcase == 'x'
              $au = 'X'
            end
            if rs['row'].downcase == 'x'
              $row = 'X'
            end
            if rs['fr_fr'].downcase == 'x'
              $fr_fr = 'X'
            end
            if rs['fr_ca'].downcase == 'x'
              $fr_ca = 'X'
            end
            if rs['fr_row'].downcase == 'x'
              $fr_row = 'X'
            end

            skuexisted = 1
            break
          end # end if
        end # end each
        # -- End Process if sku has ready existed
        if skuexisted == 1
          if $pricetier.include? '$'
            con.query "UPDATE #{table}
                       SET golivedate = '#{$golivedate}', appstatus = '#{$appstatus}', shorttitle = \"#{$shorttitle}\", longtitle = \"#{$longtitle}\", gender = '#{$gender}', agefrommonths = '#{$agefrommonths}', agetomonths = '#{$agetomonths}', skill = '#{$skill}', curriculum = \"#{$curriculum}\", longdesc = \"#{$longdesc}\", credits = '#{$credits}', platformcompatibility = '#{$platformcompatibility}', specialmsg = \"#{$specialmsg}\",teaches = \"#{$teaches}\",licenselegal = '#{$licenselegal}', licnonlic = '#{$licnonlic}', license = '#{$license}', language = '#{$language}', pricetier = '#{$pricetier}', category = '#{$category}', us = '#{$us}', ca = '#{$ca}', uk = '#{$uk}', ie = '#{$ie}', au = '#{$au}', row = '#{$row}', fr_fr = '#{$fr_fr}', fr_ca = '#{$fr_ca}', fr_row = '#{$fr_row}', lpu = '#{$lpu}', lp2 = '#{$lpu}', lp1 = '#{$lp1}', lgs = '#{$lgs}', lex = '#{$lex}', lpr = '#{$lpr}', lf_char = \"#{$character}\"
                       WHERE sku = '#{$sku}';"
          else
            con.query "UPDATE #{table}
                       SET golivedate = '#{$golivedate}', appstatus = '#{$appstatus}', shorttitle = \"#{$shorttitle}\", longtitle = \"#{$longtitle}\", gender = '#{$gender}', agefrommonths = '#{$agefrommonths}', agetomonths = '#{$agetomonths}', skill = '#{$skill}', curriculum = \"#{$curriculum}\", longdesc = \"#{$longdesc}\", credits = '#{$credits}', platformcompatibility = '#{$platformcompatibility}', specialmsg = \"#{$specialmsg}\",teaches = \"#{$teaches}\",licenselegal = '#{$licenselegal}', licnonlic = '#{$licnonlic}', license = '#{$license}', language = '#{$language}', category = '#{$category}', us = '#{$us}', ca = '#{$ca}', uk = '#{$uk}', ie = '#{$ie}', au = '#{$au}', row = '#{$row}', fr_fr = '#{$fr_fr}', fr_ca = '#{$fr_ca}', fr_row = '#{$fr_row}', lpu = '#{$lpu}', lp2 = '#{$lpu}', lp1 = '#{$lp1}', lgs = '#{$lgs}', lex = '#{$lex}', lpr = '#{$lpr}', lf_char = \"#{$character}\"
                       WHERE sku = '#{$sku}';"
          end
        else
          con.query "INSERT INTO #{table} (golivedate,appstatus,sku,shorttitle,longtitle,gender,agefrommonths,agetomonths,skill,curriculum,longdesc,credits,platformcompatibility,specialmsg,teaches,licenselegal,licnonlic,license,language,pricetier,category,us,ca,uk,ie,au,row,fr_fr,fr_ca,fr_row,lpu,lp2,lp1,lgs,lex,lpr,lf_char)
                     VALUES ('#{$golivedate}','#{$appstatus}','#{$sku}',\"#{$shorttitle}\",\"#{$longtitle}\",'#{$gender}','#{$agefrommonths}','#{$agetomonths}','#{$skill}',\"#{$curriculum}\",\"#{$longdesc}\",'#{$credits}','#{$platformcompatibility}',\"#{$specialmsg}\",\"#{$teaches}\",'#{$licenselegal}','#{$licnonlic}',
                     '#{$license}','#{$language}','#{$pricetier}','#{$category}','#{$us}','#{$ca}','#{$uk}','#{$ie}','#{$au}','#{$row}','#{$fr_fr}','#{$fr_ca}','#{$fr_row}','#{$lpu}','#{$lp2}','#{$lp1}','#{$lgs}','#{$lex}','#{$lpr}',\"#{$character}\");"
        end
      end # enc each parent
    else
      raise 'An error occurred. Please try again or contact your administrator.'
    end
  end
end

