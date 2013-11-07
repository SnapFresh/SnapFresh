ruby /AllIncomeFoods/db/cronjob.rb
psql allincomefoods -U 'aif' -c "DELETE * from retailers;"
grep -v '"NULL"' all.csv | psql allincomefoods_dev -c "copy retailers (name, lon, lat, street, city, state, zip, zip_plus_four) from stdin null as 'NULL' csv;"

