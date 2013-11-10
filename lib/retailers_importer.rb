require 'csv'

class RetailersImporter

  def run
    puts "Ensuring old data is removed..."
    delete_zip_folder
    delete_csv_files

    puts "Downloading retailer data..."
    download_zipped_retailer_data

    puts "Unziping folder"
    unzip_folder

    puts "Deleting all retailers"
    delete_retailers

    puts "Loading retailers..."
    load_retailers

    puts "Cleaning up"
    delete_zip_folder
    delete_csv_files

    puts "Data refresh completed"
  end

  def download_zipped_retailer_data
    system "wget http://snap-load-balancer-244858692.us-east-1.elb.amazonaws.com/snap/export/Nationwide.zip -P ./downloads/"
  end

  def unzip_folder
    system("unzip -o ./tmp/downloads/Nationwide.zip -d ./tmp/downloads")
  end

  def delete_retailers
    Retailer.delete_all
  end

  def load_retailers
    CSV.foreach(filename, {headers: true}) do |row|
      puts "10K row insertion milestone: #{$.}" if ($. % 10000) == 0

      retailer = Retailer.new
      retailer.name = row[0]
      retailer.lat = row[2]
      retailer.lon = row[1]
      retailer.street = row[3]
      retailer.street << " " + row[4] if row[4].present?
      retailer.city = row[5]
      retailer.state = row[6]
      retailer.zip = row[7]
      retailer.zip_plus_four = row[8]
      retailer.save
    end
  end

  def delete_csv_files
    begin
      Dir.glob("./tmp/downloads/*.csv").each do |file|
        File.delete(file)
      end
    rescue
      puts "No csv files to remove"
    end
  end

  def delete_zip_folder
    begin
      File.delete("tmp/downloads/Nationwide.zip")
    rescue
      puts "No zip folder to delete"
    end
  end

  def filename
    Dir.glob("./tmp/downloads/*.csv")[0]
  end

end
