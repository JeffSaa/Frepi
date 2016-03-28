namespace :script do
  desc "Changin url of proucts images to cloud front domain"
  
  CLOUDFRONT_URL = 'http://d3vanxn68n36vc.cloudfront.net/'

  task cloud_front: :environment do
    Product.find_each do |product|
      unless product.image.nil?
        original_image = product.image
        product.image = product.image.gsub('http://s3-sa-east-1.amazonaws.com/frepi/', CLOUDFRONT_URL)
        puts "#{original_image} changed to: #{product.image}"
        puts "status #{product.save}"
      end
    end
  end

end
