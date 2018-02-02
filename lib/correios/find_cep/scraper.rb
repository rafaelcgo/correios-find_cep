require 'csv'
require 'net/http'
require 'nokogiri'

module Correios
  module FindCep
    # Scraps the Correios webpage in order to create CSV files with Cities CEP intervals and
    # UF CEP intervals. Each one of these infos will be available at a separate CSV file.
    class Scraper
      BUSCAFAIXA_URL = 'http://www.buscacep.correios.com.br/sistemas/buscacep/ResultadoBuscaFaixaCEP.cfm'
      TABLE_SELECTOR = 'table.tmptabela'
      TOTAL_ENTRIES_SELECTOR = '.ctrlcontent'
      ROWS_PER_PAGE = 50
      UFS = %w(AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO)
      STATES = {
        'AC' => 'Acre',
        'AL' => 'Alagoas',
        'AM' => 'Amazonas',
        'AP' => 'Amapá',
        'BA' => 'Bahia',
        'CE' => 'Ceará',
        'DF' => 'Distrito Federal',
        'ES' => 'Espírito Santo',
        'GO' => 'Goiás',
        'MA' => 'Maranhão',
        'MG' => 'Minas Gerais',
        'MS' => 'Mato Grosso do Sul',
        'MT' => 'Mato Grosso',
        'PA' => 'Pará',
        'PB' => 'Paraíba',
        'PE' => 'Pernambuco',
        'PI' => 'Piauí',
        'PR' => 'Paraná',
        'RJ' => 'Rio de Janeiro',
        'RN' => 'Rio Grande do Norte',
        'RO' => 'Rondônia',
        'RR' => 'Roraima',
        'RS' => 'Rio Grande do Sul',
        'SC' => 'Santa Catarina',
        'SE' => 'Sergipe',
        'SP' => 'São Paulo',
        'TO' => 'Tocantins',
      }


      # Initialize the needed variables according to the constants defined
      def initialize(params)
        @uri = URI.parse(BUSCAFAIXA_URL)
        @timestamp = Time.zone.now.strftime('%Y%m%d-%H%M%S')
        @kind = params[:kind] || 'database'
      end

      def scrap_cities_and_ufs_tables
        @should_scrap_cities_table = true
        @should_scrap_ufs_table = true
        scrap_tables
      end

      def scrap_cities_table
        @should_scrap_cities_table = true
        @should_scrap_ufs_table = false
        scrap_tables
      end

      def scrap_ufs_table
        @should_scrap_cities_table = false
        @should_scrap_ufs_table = true
        scrap_tables
      end

      # Scraps the Correios webpage. Fetches the number of entries for each UF and saves at +total+.
      # Loops trough all the UFs and all Cities until everything has been scrapped.
      # If <tt>scrap_ufs_table?(pagini)</tt> is false, won't scrap UFs.
      # If <tt>scrap_cities_table?</tt> is false, won't scrap Cities.
      def scrap_tables
        destroy_all_previous_records_from_database if @kind == 'database'

        UFS.each do |uf|
          puts "Scrapping info from #{uf} ..."

          pagini = 1
          pagfim = ROWS_PER_PAGE
          total = ROWS_PER_PAGE

          while pagini < total
            data = {
              :UF => uf,
              :Localidade => '**',
              :Bairro => '',
              :qtdrow => ROWS_PER_PAGE.to_s,
              :pagini => pagini.to_s,
              :pagfim => pagfim.to_s,
            }
            response = Net::HTTP.post_form(uri, data)
            page = Nokogiri::HTML(response.body)

            uf_table = page.css(TABLE_SELECTOR).first
            cities_table = page.css(TABLE_SELECTOR).last

            if scrap_ufs_table?(pagini)
              if @kind == 'csv'
                scrap_ufs_table_to_csv(uf, uf_table, filepath(:ufs))
              elsif @kind == 'database'
                scrap_ufs_table_to_database(uf, uf_table)
              end
            end

            break if not scrap_cities_table?

            if @kind == 'csv'
              scrap_cities_table_to_csv(uf, cities_table, filepath(:cities))
            elsif @kind == 'database'
              scrap_cities_table_to_database(uf, cities_table)
            end

            total = get_total_entries(page)
            pagini = pagfim + 1
            pagfim = pagfim + ROWS_PER_PAGE
          end
        end
      end

      private
        attr_reader :uri, :timestamp, :should_scrap_ufs_table, :should_scrap_cities_table

        def destroy_all_previous_records_from_database
          Correios::FindCep::City.destroy_all if @should_scrap_cities_table
          Correios::FindCep::Uf.destroy_all if @should_scrap_ufs_table
        end

        # Extracts the correios CEP string to an array, stripping dashes
        # @example:
        #   extract_cep_interval("69900-000 a 69999-999") #=> ["69900000", "69999999"]
        def extract_cep_interval(text)
          ceps = text.split('a')
          ceps.map!(&:strip)
          ceps.map! { |cep| cep.gsub('-', '') }
          ceps
        end

        def filepath(kind)
          "#{timestamp}_correios_#{kind}.csv"
        end

        def get_total_entries(page)
          page.css(TOTAL_ENTRIES_SELECTOR).css('div')[3].next.text.strip.split('de').last.strip.to_i
        end

        def scrap_cities_table?
          should_scrap_cities_table
        end

        # The table containing Cities CEP intervals information is the second table
        # with class +TABLE_SELECTOR+. The interval cell will only hold one interval.
        # But the same city can appear more than once.
        # Examples:
        #   * São Paulo: 1000001 a 5999999
        #   * São Paulo: 8000000 a 8499999
        def scrap_cities_table_to_array(uf, table)
          rows = []
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            next if tr.blank?

            city               = tr.css('td')[0].text
            cep_start, cep_end = extract_cep_interval(tr.css('td')[1].text)
            situation          = tr.css('td')[2].text
            kind               = tr.css('td')[3].text

            if kind == 'Total do município'
              rows << [uf, city.downcase, cep_start, cep_end, situation, kind]
            end
          end
          rows
        end

        def scrap_cities_table_to_csv(uf, table, filepath)
          CSV.open(filepath, 'ab') do |csv|
            scrap_cities_table_to_array(uf, table).each { |row| csv << row }
          end
        end

        def scrap_cities_table_to_database(uf, table)
          records = scrap_cities_table_to_array(uf, table).map do |row|
            {uf: row[0], city: row[1], cep_min: row[2], cep_max: row[3]}
          end
          Correios::FindCep::City.create(records)
        end

        def scrap_ufs_table?(pagini)
          pagini == 1 && should_scrap_ufs_table
        end

        # The table containing UF CEP intervals information is the first table
        # with class +TABLE_SELECTOR+. The interval cell can have one or multiple intervals.
        # Examples:
        #   * AC: 69900-000 a 69999-999
        #   * AM: 69000-000 a 69299-999, 69400-000 a 69899-999
        def scrap_ufs_table_to_array(uf, table)
          rows = []
          multiple_cep_interval = table.css('tr').last.css('td').last.text
          multiple_cep_interval.split(',').each do |cep_interval|
            cep_start, cep_end = extract_cep_interval(cep_interval)
            rows << [uf, cep_start, cep_end]
          end
          rows
        end

        def scrap_ufs_table_to_csv(uf, table, filepath)
          CSV.open(filepath, 'ab') do |csv|
            scrap_ufs_table_to_array(uf, table).each { |row| csv << row }
          end
        end

        def scrap_ufs_table_to_database(uf, table)
          records = scrap_ufs_table_to_array(uf, table).map do |row|
            {uf: row[0], state: state_from_uf(row[0]), cep_min: row[1], cep_max: row[2]}
          end
          Correios::FindCep::Uf.create(records)
        end

        def state_from_uf(uf)
          STATES[uf.to_s.upcase]
        end
    end
  end
end
