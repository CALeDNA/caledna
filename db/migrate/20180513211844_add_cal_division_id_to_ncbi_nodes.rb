class AddCalDivisionIdToNcbiNodes < ActiveRecord::Migration[5.0]
  def change
    add_reference :ncbi_nodes, :cal_division, foreign_key: { to_table: :ncbi_divisions }


    # UPDATE ncbi_nodes SET cal_division_id = division_id

    # change rodents to animals
    # UPDATE ncbi_nodes SET cal_division_id = 12 WHERE cal_division_id = 5
    # change mammals to animals
    # UPDATE ncbi_nodes SET cal_division_id = 12 WHERE cal_division_id = 2
    # change prmiates to animals
    # UPDATE ncbi_nodes SET cal_division_id = 12 WHERE cal_division_id = 6
    # change Invertebrates to animals
    # UPDATE ncbi_nodes SET cal_division_id = 12 WHERE cal_division_id = 1
    # change vertebrates to animals
    # UPDATE ncbi_nodes SET cal_division_id = 12 WHERE cal_division_id = 10

    # change some plants and fungi to plants
    # UPDATE ncbi_nodes SET cal_division_id = 14 WHERE hierarchy ->> 'kingdom' = '33090' and cal_division_id != 11;
    # change some plants and fungi to fungi
    # UPDATE ncbi_nodes SET cal_division_id = 13 WHERE hierarchy ->> 'kingdom' = '4751' and cal_division_id != 11;

    # change Phages to virus
    # UPDATE ncbi_nodes SET cal_division_id = 9 WHERE cal_division_id = 3;
    # change some bacteria to Archaea
    # UPDATE ncbi_nodes SET cal_division_id = 16 where  hierarchy ->> 'superkingdom' = '2157' and cal_division_id != 11;

    # TODO
    # 34339 remaining plants and fungi
    #

  end
end
