class ImportService
  require 'csv'

  def call(file)
    # opened_file = File.open(file)
    options = { headers: true, col_sep: ';', encoding: "UTF-8" }
    ApplicationLogger.new.info "CSV import starting"
    begin
      CSV.open(file.path, **options).each do |row|
        next if empty_row?(row)
        yield row
      end
    rescue Exception => e
      ApplicationLogger.new.error "CSV import error: #{e.message}"
    end
  end

  private

  def empty_row?(row)
    row.all? { |_, cell| cell.nil? }
  end

  def convert_to_utf8_encoding(original_file)
    original_string = original_file.read
    final_string = original_string.encode(invalid: :replace, undef: :replace, replace: '') #If you'd rather invalid characters be replaced with something else, do so here.
    final_file = Tempfile.new('import') #No need to save a real File
    final_file.write(final_string)
    final_file.close #Don't forget me
    final_file
  end

end
