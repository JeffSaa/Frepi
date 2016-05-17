namespace :products_utilities do
  desc "TODO"
  require 'roo'
  
  task upload_file: :environment do

    spreadsheet = Roo::Spreadsheet.open(Rails.root + 'public/products.xlsx', extension: :xlsx)

    spreadsheet = spreadsheet.sheet('Oficial')

    spreadsheet.each_row_streaming(offset: 1) do |row|
      params = {}
      row.each_with_index do |column, index|
        case index
        when 0
          params[:id] = column.value.to_i
        when 1
          params[:name] = column.value
        when 2
          params[:size] = column.value == "'" ? nil : column.value
        when 3
          params[:description] = column.value == "'" ? nil : column.value
        when 4
          params[:store_price] = column.value.to_i
        when 5
          params[:iva] = column.value.to_f
        when 6
          params[:percentage] = column.value.to_f
        when 7
          params[:frepi_price] = column.value.to_i
        when 8
          params[:subcategory_id] = column.value.to_i
        when 9
          params[:sucursal_id] = column.value.to_i
        end
      end
      p params
      break if params[:name].nil?
      sucursal = Sucursal.find(params[:sucursal_id])
        

      if Product.exists? params[:id]
        # Updated the sucursal
        sucursalProduct = SucursalsProduct.where(product_id: params[:id]).first
        sucursalProduct.update(sucursal_id: params[:sucursal_id])

        # Udpate product's attribute
        p sucursalProduct.product.update(id: params[:id], name: params[:name], size: params[:size], 
                        description: params[:description], store_price: params[:store_price], 
                        iva: params[:iva], percentage: params[:percentage],
                        frepi_price: params[:frepi_price], subcategory_id: params[:subcategory_id])
      else
        p sucursal.products.create!(id: params[:id], name: params[:name], size: params[:size], description: params[:description],
                                  store_price: params[:store_price], iva: params[:iva], percentage: params[:percentage],
                                  frepi_price: params[:frepi_price], subcategory_id: params[:subcategory_id])        
      end
        
    end

  end

end
