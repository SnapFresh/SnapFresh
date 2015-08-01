require 'csv'
require 'tmpdir'

class RetailersImporter
  SLICE_SIZE = 1_000
  DATA_URL = 'http://snap-load-balancer-244858692.us-east-1.elb.amazonaws.com/snap/export/Nationwide.zip'

  def self.call
    Dir.mktmpdir('retailers_importer') do |dir|
      system "wget #{DATA_URL} -P #{dir}"
      system("unzip -o #{dir}/Nationwide.zip -d #{dir}")
      ActiveRecord::Base.connection.transaction do
        Retailer.delete_all
        load_csv(dir)
      end
    end
  end

  private

  def self.load_csv(dir)
    csv = CSV.open(filename(dir))
    csv.readline
    csv.each_slice(SLICE_SIZE).each do |rows|
      db_insert(rows)
    end
  end

  def self.db_insert(rows)
    ActiveRecord::Base.connection.execute(
      "INSERT INTO retailers (name, lat, lon, street, city, state, zip, zip_plus_four, created_at, updated_at)
       VALUES #{map_to_values(rows)}"
    )
  end

  def self.map_to_values(rows)
    rows.map{ |row| insert_value(row) }.join(',')
  end

  def self.insert_value(row)
    "($q$#{row[0]}$q$, #{row[2]}, #{row[1]}, $q$#{street(row[3], row[4])}$q$, $q$#{row[5]}$q$, $q$#{row[6]}$q$, #{row[7]}, $q$#{row[8]}$q$, NOW(), NOW())"
  end

  def self.filename(dir)
    Dir.glob("#{dir}/*.csv")[0]
  end

  def self.street(row3, row4)
    row4.present? ? row3 + " "  + row4 : row3
  end
end
