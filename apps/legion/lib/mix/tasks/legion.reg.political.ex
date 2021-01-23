defmodule Mix.Tasks.Legion.Reg.Political do
  @moduledoc """
  Registers nationalities to the repository.
  """
  use Legion.RegistryDirectory.Synchronization, site: Legion.Messaging.Settings, repo: Legion.Repo

  alias Legion.Repo
  alias Legion.Identity.Information.Political.{Region, Subregion, IntermediateRegion, Country}

  def put_region(name, code) do
    Repo.insert!(%Region{name: downcase_if_not_nil(name),
                         code: Integer.parse(code) |> elem(0)})

    Mix.shell().info("added region #{name}")
  rescue
    Ecto.ConstraintError ->
      Mix.shell().info("cannot add region #{name}, it is already loaded")
  end

  def put_subregion(name, region_name, code) do
    Repo.insert!(%Subregion{
      name: downcase_if_not_nil(name),
      region_name: downcase_if_not_nil(region_name),
      code: Integer.parse(code) |> elem(0)
    })

    Mix.shell().info("added subregion #{name}")
  rescue
    Ecto.ConstraintError ->
      Mix.shell().info("cannot add subregion #{name}, it is already loaded")
  end

  def put_intermediate_region(name, _, subregion_name, code) do
    Repo.insert!(%IntermediateRegion{
      name: downcase_if_not_nil(name),
      subregion_name: downcase_if_not_nil(subregion_name),
      code: Integer.parse(code) |> elem(0)
    })

    Mix.shell().info("added intermediate region #{name}")
  rescue
    Ecto.ConstraintError ->
      Mix.shell().info("cannot add intermediate region #{name}, it is already loaded")
  end

  def put_country(
        name,
        two_letter,
        three_letter,
        iso_3166,
        region_name,
        subregion_name,
        intermediate_region_name
      ) do
    Repo.insert!(%Country{
      name: downcase_if_not_nil(name),
      two_letter: downcase_if_not_nil(two_letter),
      three_letter: downcase_if_not_nil(three_letter),
      iso_3166: iso_3166,
      region_name: downcase_if_not_nil(region_name),
      subregion_name: downcase_if_not_nil(subregion_name),
      intermediate_region_name: downcase_if_not_nil(intermediate_region_name)
    })

    Mix.shell().info("added country #{name}")
  rescue
    Ecto.ConstraintError ->
      Mix.shell().info("cannot add country #{name}, it is already loaded")
  end

  defp downcase_if_not_nil(string) when is_binary(string),
    do: String.downcase(string)
  defp downcase_if_not_nil(string) when is_nil(string),
    do: nil

  def sync do
    Mix.shell().info("== Synchronizing regions")

    # 1. Regions
    put_region "Asia", "142"
    put_region "Europe", "150"
    put_region "Oceania", "009"
    put_region "Africa", "002"
    put_region "Americas", "019"

    Mix.shell().info("== Finished synchronizing regions")
    Mix.shell().info("== Synchronizing subregions")

    # 2. Subregions
    put_subregion "Australia and New Zealand", "Oceania", "053"
    put_subregion "Central Asia", "Asia", "143"
    put_subregion "Eastern Asia", "Asia", "030"
    put_subregion "Eastern Europe", "Europe", "151"
    put_subregion "Latin America and the Caribbean", "Americas", "419"
    put_subregion "Melanesia", "Oceania", "054"
    put_subregion "Micronesia", "Oceania", "057"
    put_subregion "Northern Africa", "Africa", "015"
    put_subregion "Northern America", "Americas", "021"
    put_subregion "Northern Europe", "Europe", "154"
    put_subregion "Polynesia", "Oceania", "061"
    put_subregion "South-eastern Asia", "Asia", "035"
    put_subregion "Southern Asia", "Asia", "034"
    put_subregion "Southern Europe", "Europe", "039"
    put_subregion "Sub-Saharan Africa", "Africa", "202"
    put_subregion "Western Asia", "Asia", "145"
    put_subregion "Western Europe", "Europe", "155"

    Mix.shell().info("== Finished synchronizing subregions")
    Mix.shell().info("== Synchronizing intermediate regions")

    # 3. Intermediate regions
    put_intermediate_region "Middle Africa", "Africa", "Sub-Saharan Africa", "017"
    put_intermediate_region "Southern Africa", "Africa", "Sub-Saharan Africa", "018"
    put_intermediate_region "Central America", "Americas", "Latin America and the Caribbean", "013"
    put_intermediate_region "Caribbean", "Americas", "Latin America and the Caribbean", "029"
    put_intermediate_region "Western Africa", "Africa", "Sub-Saharan Africa", "011"
    put_intermediate_region "Channel Islands", "Europe", "Northern Europe", "830"
    put_intermediate_region "Eastern Africa", "Africa", "Sub-Saharan Africa", "014"
    put_intermediate_region "South America", "Americas", "Latin America and the Caribbean", "005"

    Mix.shell().info("== Finished synchronizing intermediate regions")
    Mix.shell().info("== Synchronizing countries")

    # 4. Countries
    put_country "Afghanistan", "AF", "AFG", "ISO 3166-2:AF", "Asia", "Southern Asia", nil
    put_country "Albania", "AL", "ALB", "ISO 3166-2:AL", "Europe", "Southern Europe", nil
    put_country "Algeria", "DZ", "DZA", "ISO 3166-2:DZ", "Africa", "Northern Africa", nil
    put_country "American Samoa", "AS", "ASM", "ISO 3166-2:AS", "Oceania", "Polynesia", nil
    put_country "Andorra", "AD", "AND", "ISO 3166-2:AD", "Europe", "Southern Europe", nil
    put_country "Angola", "AO", "AGO", "ISO 3166-2:AO", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Anguilla", "AI", "AIA", "ISO 3166-2:AI", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Antarctica", "AQ", "ATA", "ISO 3166-2:AQ", nil, nil, nil
    put_country "Antigua and Barbuda", "AG", "ATG", "ISO 3166-2:AG", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Argentina", "AR", "ARG", "ISO 3166-2:AR", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Armenia", "AM", "ARM", "ISO 3166-2:AM", "Asia", "Western Asia", nil
    put_country "Aruba", "AW", "ABW", "ISO 3166-2:AW", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Australia", "AU", "AUS", "ISO 3166-2:AU", "Oceania", "Australia and New Zealand", nil
    put_country "Austria", "AT", "AUT", "ISO 3166-2:AT", "Europe", "Western Europe", nil
    put_country "Azerbaijan", "AZ", "AZE", "ISO 3166-2:AZ", "Asia", "Western Asia", nil
    put_country "Åland Islands", "AX", "ALA", "ISO 3166-2:AX", "Europe", "Northern Europe", nil
    put_country "Bahamas", "BS", "BHS", "ISO 3166-2:BS", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Bahrain", "BH", "BHR", "ISO 3166-2:BH", "Asia", "Western Asia", nil
    put_country "Bangladesh", "BD", "BGD", "ISO 3166-2:BD", "Asia", "Southern Asia", nil
    put_country "Barbados", "BB", "BRB", "ISO 3166-2:BB", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Belarus", "BY", "BLR", "ISO 3166-2:BY", "Europe", "Eastern Europe", nil
    put_country "Belgium", "BE", "BEL", "ISO 3166-2:BE", "Europe", "Western Europe", nil
    put_country "Belize", "BZ", "BLZ", "ISO 3166-2:BZ", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Benin", "BJ", "BEN", "ISO 3166-2:BJ", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Bermuda", "BM", "BMU", "ISO 3166-2:BM", "Americas", "Northern America", nil
    put_country "Bhutan", "BT", "BTN", "ISO 3166-2:BT", "Asia", "Southern Asia", nil
    put_country "Bolivia (Plurinational State of)", "BO", "BOL", "ISO 3166-2:BO", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Bonaire, Sint Eustatius and Saba", "BQ", "BES", "ISO 3166-2:BQ", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Bosnia and Herzegovina", "BA", "BIH", "ISO 3166-2:BA", "Europe", "Southern Europe", nil
    put_country "Botswana", "BW", "BWA", "ISO 3166-2:BW", "Africa", "Sub-Saharan Africa", "Southern Africa"
    put_country "Bouvet Island", "BV", "BVT", "ISO 3166-2:BV", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Brazil", "BR", "BRA", "ISO 3166-2:BR", "Americas", "Latin America and the Caribbean", "South America"
    put_country "British Indian Ocean Territory", "IO", "IOT", "ISO 3166-2:IO", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Brunei Darussalam", "BN", "BRN", "ISO 3166-2:BN", "Asia", "South-eastern Asia", nil
    put_country "Bulgaria", "BG", "BGR", "ISO 3166-2:BG", "Europe", "Eastern Europe", nil
    put_country "Burkina Faso", "BF", "BFA", "ISO 3166-2:BF", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Burundi", "BI", "BDI", "ISO 3166-2:BI", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Cabo Verde", "CV", "CPV", "ISO 3166-2:CV", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Cambodia", "KH", "KHM", "ISO 3166-2:KH", "Asia", "South-eastern Asia", nil
    put_country "Cameroon", "CM", "CMR", "ISO 3166-2:CM", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Canada", "CA", "CAN", "ISO 3166-2:CA", "Americas", "Northern America", nil
    put_country "Cayman Islands", "KY", "CYM", "ISO 3166-2:KY", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Central African Republic", "CF", "CAF", "ISO 3166-2:CF", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Chad", "TD", "TCD", "ISO 3166-2:TD", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Chile", "CL", "CHL", "ISO 3166-2:CL", "Americas", "Latin America and the Caribbean", "South America"
    put_country "China", "CN", "CHN", "ISO 3166-2:CN", "Asia", "Eastern Asia", nil
    put_country "Christmas Island", "CX", "CXR", "ISO 3166-2:CX", "Oceania", "Australia and New Zealand", nil
    put_country "Cocos (Keeling) Islands", "CC", "CCK", "ISO 3166-2:CC", "Oceania", "Australia and New Zealand", nil
    put_country "Colombia", "CO", "COL", "ISO 3166-2:CO", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Comoros", "KM", "COM", "ISO 3166-2:KM", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Congo", "CG", "COG", "ISO 3166-2:CG", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Congo (Democratic Republic of the)", "CD", "COD", "ISO 3166-2:CD", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Cook Islands", "CK", "COK", "ISO 3166-2:CK", "Oceania", "Polynesia", nil
    put_country "Costa Rica", "CR", "CRI", "ISO 3166-2:CR", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Côte d'Ivoire", "CI", "CIV", "ISO 3166-2:CI", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Croatia", "HR", "HRV", "ISO 3166-2:HR", "Europe", "Southern Europe", nil
    put_country "Cuba", "CU", "CUB", "ISO 3166-2:CU", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Curaçao", "CW", "CUW", "ISO 3166-2:CW", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Cyprus", "CY", "CYP", "ISO 3166-2:CY", "Asia", "Western Asia", nil
    put_country "Czechia", "CZ", "CZE", "ISO 3166-2:CZ", "Europe", "Eastern Europe", nil
    put_country "Denmark", "DK", "DNK", "ISO 3166-2:DK", "Europe", "Northern Europe", nil
    put_country "Djibouti", "DJ", "DJI", "ISO 3166-2:DJ", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Dominica", "DM", "DMA", "ISO 3166-2:DM", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Dominican Republic", "DO", "DOM", "ISO 3166-2:DO", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Ecuador", "EC", "ECU", "ISO 3166-2:EC", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Egypt", "EG", "EGY", "ISO 3166-2:EG", "Africa", "Northern Africa", nil
    put_country "El Salvador", "SV", "SLV", "ISO 3166-2:SV", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Equatorial Guinea", "GQ", "GNQ", "ISO 3166-2:GQ", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Eritrea", "ER", "ERI", "ISO 3166-2:ER", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Estonia", "EE", "EST", "ISO 3166-2:EE", "Europe", "Northern Europe", nil
    put_country "Eswatini", "SZ", "SWZ", "ISO 3166-2:SZ", "Africa", "Sub-Saharan Africa", "Southern Africa"
    put_country "Ethiopia", "ET", "ETH", "ISO 3166-2:ET", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Falkland Islands (Malvinas)", "FK", "FLK", "ISO 3166-2:FK", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Faroe Islands", "FO", "FRO", "ISO 3166-2:FO", "Europe", "Northern Europe", nil
    put_country "Fiji", "FJ", "FJI", "ISO 3166-2:FJ", "Oceania", "Melanesia", nil
    put_country "Finland", "FI", "FIN", "ISO 3166-2:FI", "Europe", "Northern Europe", nil
    put_country "France", "FR", "FRA", "ISO 3166-2:FR", "Europe", "Western Europe", nil
    put_country "French Guiana", "GF", "GUF", "ISO 3166-2:GF", "Americas", "Latin America and the Caribbean", "South America"
    put_country "French Polynesia", "PF", "PYF", "ISO 3166-2:PF", "Oceania", "Polynesia", nil
    put_country "French Southern Territories", "TF", "ATF", "ISO 3166-2:TF", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Gabon", "GA", "GAB", "ISO 3166-2:GA", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Gambia", "GM", "GMB", "ISO 3166-2:GM", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Georgia", "GE", "GEO", "ISO 3166-2:GE", "Asia", "Western Asia", nil
    put_country "Germany", "DE", "DEU", "ISO 3166-2:DE", "Europe", "Western Europe", nil
    put_country "Ghana", "GH", "GHA", "ISO 3166-2:GH", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Gibraltar", "GI", "GIB", "ISO 3166-2:GI", "Europe", "Southern Europe", nil
    put_country "Greece", "GR", "GRC", "ISO 3166-2:GR", "Europe", "Southern Europe", nil
    put_country "Greenland", "GL", "GRL", "ISO 3166-2:GL", "Americas", "Northern America", nil
    put_country "Grenada", "GD", "GRD", "ISO 3166-2:GD", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Guadeloupe", "GP", "GLP", "ISO 3166-2:GP", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Guam", "GU", "GUM", "ISO 3166-2:GU", "Oceania", "Micronesia", nil
    put_country "Guatemala", "GT", "GTM", "ISO 3166-2:GT", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Guernsey", "GG", "GGY", "ISO 3166-2:GG", "Europe", "Northern Europe", "Channel Islands"
    put_country "Guinea", "GN", "GIN", "ISO 3166-2:GN", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Guinea-Bissau", "GW", "GNB", "ISO 3166-2:GW", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Guyana", "GY", "GUY", "ISO 3166-2:GY", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Haiti", "HT", "HTI", "ISO 3166-2:HT", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Heard Island and McDonald Islands", "HM", "HMD", "ISO 3166-2:HM", "Oceania", "Australia and New Zealand", nil
    put_country "Holy See", "VA", "VAT", "ISO 3166-2:VA", "Europe", "Southern Europe", nil
    put_country "Honduras", "HN", "HND", "ISO 3166-2:HN", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Hong Kong", "HK", "HKG", "ISO 3166-2:HK", "Asia", "Eastern Asia", nil
    put_country "Hungary", "HU", "HUN", "ISO 3166-2:HU", "Europe", "Eastern Europe", nil
    put_country "Iceland", "IS", "ISL", "ISO 3166-2:IS", "Europe", "Northern Europe", nil
    put_country "India", "IN", "IND", "ISO 3166-2:IN", "Asia", "Southern Asia", nil
    put_country "Indonesia", "ID", "IDN", "ISO 3166-2:ID", "Asia", "South-eastern Asia", nil
    put_country "Iran (Islamic Republic of)", "IR", "IRN", "ISO 3166-2:IR", "Asia", "Southern Asia", nil
    put_country "Iraq", "IQ", "IRQ", "ISO 3166-2:IQ", "Asia", "Western Asia", nil
    put_country "Ireland", "IE", "IRL", "ISO 3166-2:IE", "Europe", "Northern Europe", nil
    put_country "Isle of Man", "IM", "IMN", "ISO 3166-2:IM", "Europe", "Northern Europe", nil
    put_country "Israel", "IL", "ISR", "ISO 3166-2:IL", "Asia", "Western Asia", nil
    put_country "Italy", "IT", "ITA", "ISO 3166-2:IT", "Europe", "Southern Europe", nil
    put_country "Jamaica", "JM", "JAM", "ISO 3166-2:JM", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Japan", "JP", "JPN", "ISO 3166-2:JP", "Asia", "Eastern Asia", nil
    put_country "Jersey", "JE", "JEY", "ISO 3166-2:JE", "Europe", "Northern Europe", "Channel Islands"
    put_country "Jordan", "JO", "JOR", "ISO 3166-2:JO", "Asia", "Western Asia", nil
    put_country "Kazakhstan", "KZ", "KAZ", "ISO 3166-2:KZ", "Asia", "Central Asia", nil
    put_country "Kenya", "KE", "KEN", "ISO 3166-2:KE", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Kiribati", "KI", "KIR", "ISO 3166-2:KI", "Oceania", "Micronesia", nil
    put_country "Korea (Democratic People's Republic of)", "KP", "PRK", "ISO 3166-2:KP", "Asia", "Eastern Asia", nil
    put_country "Korea (Republic of)", "KR", "KOR", "ISO 3166-2:KR", "Asia", "Eastern Asia", nil
    put_country "Kuwait", "KW", "KWT", "ISO 3166-2:KW", "Asia", "Western Asia", nil
    put_country "Kyrgyzstan", "KG", "KGZ", "ISO 3166-2:KG", "Asia", "Central Asia", nil
    put_country "Lao People's Democratic Republic", "LA", "LAO", "ISO 3166-2:LA", "Asia", "South-eastern Asia", nil
    put_country "Latvia", "LV", "LVA", "ISO 3166-2:LV", "Europe", "Northern Europe", nil
    put_country "Lebanon", "LB", "LBN", "ISO 3166-2:LB", "Asia", "Western Asia", nil
    put_country "Lesotho", "LS", "LSO", "ISO 3166-2:LS", "Africa", "Sub-Saharan Africa", "Southern Africa"
    put_country "Liberia", "LR", "LBR", "ISO 3166-2:LR", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Libya", "LY", "LBY", "ISO 3166-2:LY", "Africa", "Northern Africa", nil
    put_country "Liechtenstein", "LI", "LIE", "ISO 3166-2:LI", "Europe", "Western Europe", nil
    put_country "Lithuania", "LT", "LTU", "ISO 3166-2:LT", "Europe", "Northern Europe", nil
    put_country "Luxembourg", "LU", "LUX", "ISO 3166-2:LU", "Europe", "Western Europe", nil
    put_country "Macao", "MO", "MAC", "ISO 3166-2:MO", "Asia", "Eastern Asia", nil
    put_country "Macedonia (the former Yugoslav Republic of)", "MK", "MKD", "ISO 3166-2:MK", "Europe", "Southern Europe", nil
    put_country "Madagascar", "MG", "MDG", "ISO 3166-2:MG", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Malawi", "MW", "MWI", "ISO 3166-2:MW", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Malaysia", "MY", "MYS", "ISO 3166-2:MY", "Asia", "South-eastern Asia", nil
    put_country "Maldives", "MV", "MDV", "ISO 3166-2:MV", "Asia", "Southern Asia", nil
    put_country "Mali", "ML", "MLI", "ISO 3166-2:ML", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Malta", "MT", "MLT", "ISO 3166-2:MT", "Europe", "Southern Europe", nil
    put_country "Marshall Islands", "MH", "MHL", "ISO 3166-2:MH", "Oceania", "Micronesia", nil
    put_country "Martinique", "MQ", "MTQ", "ISO 3166-2:MQ", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Mauritania", "MR", "MRT", "ISO 3166-2:MR", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Mauritius", "MU", "MUS", "ISO 3166-2:MU", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Mayotte", "YT", "MYT", "ISO 3166-2:YT", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Mexico", "MX", "MEX", "ISO 3166-2:MX", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Micronesia (Federated States of)", "FM", "FSM", "ISO 3166-2:FM", "Oceania", "Micronesia", nil
    put_country "Moldova (Republic of)", "MD", "MDA", "ISO 3166-2:MD", "Europe", "Eastern Europe", nil
    put_country "Monaco", "MC", "MCO", "ISO 3166-2:MC", "Europe", "Western Europe", nil
    put_country "Mongolia", "MN", "MNG", "ISO 3166-2:MN", "Asia", "Eastern Asia", nil
    put_country "Montenegro", "ME", "MNE", "ISO 3166-2:ME", "Europe", "Southern Europe", nil
    put_country "Montserrat", "MS", "MSR", "ISO 3166-2:MS", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Morocco", "MA", "MAR", "ISO 3166-2:MA", "Africa", "Northern Africa", nil
    put_country "Mozambique", "MZ", "MOZ", "ISO 3166-2:MZ", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Myanmar", "MM", "MMR", "ISO 3166-2:MM", "Asia", "South-eastern Asia", nil
    put_country "Namibia", nil, "NAM", "ISO 3166-2:NA", "Africa", "Sub-Saharan Africa", "Southern Africa"
    put_country "Nauru", "NR", "NRU", "ISO 3166-2:NR", "Oceania", "Micronesia", nil
    put_country "Nepal", "NP", "NPL", "ISO 3166-2:NP", "Asia", "Southern Asia", nil
    put_country "Netherlands", "NL", "NLD", "ISO 3166-2:NL", "Europe", "Western Europe", nil
    put_country "New Caledonia", "NC", "NCL", "ISO 3166-2:NC", "Oceania", "Melanesia", nil
    put_country "New Zealand", "NZ", "NZL", "ISO 3166-2:NZ", "Oceania", "Australia and New Zealand", nil
    put_country "Nicaragua", "NI", "NIC", "ISO 3166-2:NI", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Niger", "NE", "NER", "ISO 3166-2:NE", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Nigeria", "NG", "NGA", "ISO 3166-2:NG", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Niue", "NU", "NIU", "ISO 3166-2:NU", "Oceania", "Polynesia", nil
    put_country "Norfolk Island", "NF", "NFK", "ISO 3166-2:NF", "Oceania", "Australia and New Zealand", nil
    put_country "Northern Mariana Islands", "MP", "MNP", "ISO 3166-2:MP", "Oceania", "Micronesia", nil
    put_country "Norway", "NO", "NOR", "ISO 3166-2:NO", "Europe", "Northern Europe", nil
    put_country "Oman", "OM", "OMN", "ISO 3166-2:OM", "Asia", "Western Asia", nil
    put_country "Pakistan", "PK", "PAK", "ISO 3166-2:PK", "Asia", "Southern Asia", nil
    put_country "Palau", "PW", "PLW", "ISO 3166-2:PW", "Oceania", "Micronesia", nil
    put_country "Palestine, State of", "PS", "PSE", "ISO 3166-2:PS", "Asia", "Western Asia", nil
    put_country "Panama", "PA", "PAN", "ISO 3166-2:PA", "Americas", "Latin America and the Caribbean", "Central America"
    put_country "Papua New Guinea", "PG", "PNG", "ISO 3166-2:PG", "Oceania", "Melanesia", nil
    put_country "Paraguay", "PY", "PRY", "ISO 3166-2:PY", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Peru", "PE", "PER", "ISO 3166-2:PE", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Philippines", "PH", "PHL", "ISO 3166-2:PH", "Asia", "South-eastern Asia", nil
    put_country "Pitcairn", "PN", "PCN", "ISO 3166-2:PN", "Oceania", "Polynesia", nil
    put_country "Poland", "PL", "POL", "ISO 3166-2:PL", "Europe", "Eastern Europe", nil
    put_country "Portugal", "PT", "PRT", "ISO 3166-2:PT", "Europe", "Southern Europe", nil
    put_country "Puerto Rico", "PR", "PRI", "ISO 3166-2:PR", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Qatar", "QA", "QAT", "ISO 3166-2:QA", "Asia", "Western Asia", nil
    put_country "Réunion", "RE", "REU", "ISO 3166-2:RE", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Romania", "RO", "ROU", "ISO 3166-2:RO", "Europe", "Eastern Europe", nil
    put_country "Russian Federation", "RU", "RUS", "ISO 3166-2:RU", "Europe", "Eastern Europe", nil
    put_country "Rwanda", "RW", "RWA", "ISO 3166-2:RW", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Saint Barthélemy", "BL", "BLM", "ISO 3166-2:BL", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Saint Helena, Ascension and Tristan da Cunha", "SH", "SHN", "ISO 3166-2:SH", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Saint Kitts and Nevis", "KN", "KNA", "ISO 3166-2:KN", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Saint Lucia", "LC", "LCA", "ISO 3166-2:LC", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Saint Martin (French part)", "MF", "MAF", "ISO 3166-2:MF", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Saint Pierre and Miquelon", "PM", "SPM", "ISO 3166-2:PM", "Americas", "Northern America", nil
    put_country "Saint Vincent and the Grenadines", "VC", "VCT", "ISO 3166-2:VC", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Samoa", "WS", "WSM", "ISO 3166-2:WS", "Oceania", "Polynesia", nil
    put_country "San Marino", "SM", "SMR", "ISO 3166-2:SM", "Europe", "Southern Europe", nil
    put_country "Sao Tome and Principe", "ST", "STP", "ISO 3166-2:ST", "Africa", "Sub-Saharan Africa", "Middle Africa"
    put_country "Saudi Arabia", "SA", "SAU", "ISO 3166-2:SA", "Asia", "Western Asia", nil
    put_country "Senegal", "SN", "SEN", "ISO 3166-2:SN", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Serbia", "RS", "SRB", "ISO 3166-2:RS", "Europe", "Southern Europe", nil
    put_country "Seychelles", "SC", "SYC", "ISO 3166-2:SC", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Sierra Leone", "SL", "SLE", "ISO 3166-2:SL", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Singapore", "SG", "SGP", "ISO 3166-2:SG", "Asia", "South-eastern Asia", nil
    put_country "Sint Maarten (Dutch part)", "SX", "SXM", "ISO 3166-2:SX", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Slovakia", "SK", "SVK", "ISO 3166-2:SK", "Europe", "Eastern Europe", nil
    put_country "Slovenia", "SI", "SVN", "ISO 3166-2:SI", "Europe", "Southern Europe", nil
    put_country "Solomon Islands", "SB", "SLB", "ISO 3166-2:SB", "Oceania", "Melanesia", nil
    put_country "Somalia", "SO", "SOM", "ISO 3166-2:SO", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "South Africa", "ZA", "ZAF", "ISO 3166-2:ZA", "Africa", "Sub-Saharan Africa", "Southern Africa"
    put_country "South Georgia and the South Sandwich Islands", "GS", "SGS", "ISO 3166-2:GS", "Americas", "Latin America and the Caribbean", "South America"
    put_country "South Sudan", "SS", "SSD", "ISO 3166-2:SS", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Spain", "ES", "ESP", "ISO 3166-2:ES", "Europe", "Southern Europe", nil
    put_country "Sri Lanka", "LK", "LKA", "ISO 3166-2:LK", "Asia", "Southern Asia", nil
    put_country "Sudan", "SD", "SDN", "ISO 3166-2:SD", "Africa", "Northern Africa", nil
    put_country "Suriname", "SR", "SUR", "ISO 3166-2:SR", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Svalbard and Jan Mayen", "SJ", "SJM", "ISO 3166-2:SJ", "Europe", "Northern Europe", nil
    put_country "Sweden", "SE", "SWE", "ISO 3166-2:SE", "Europe", "Northern Europe", nil
    put_country "Switzerland", "CH", "CHE", "ISO 3166-2:CH", "Europe", "Western Europe", nil
    put_country "Syrian Arab Republic", "SY", "SYR", "ISO 3166-2:SY", "Asia", "Western Asia", nil
    put_country "Taiwan, Province of China", "TW", "TWN", "ISO 3166-2:TW", "Asia", "Eastern Asia", nil
    put_country "Tajikistan", "TJ", "TJK", "ISO 3166-2:TJ", "Asia", "Central Asia", nil
    put_country "Tanzania, United Republic of", "TZ", "TZA", "ISO 3166-2:TZ", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Thailand", "TH", "THA", "ISO 3166-2:TH", "Asia", "South-eastern Asia", nil
    put_country "Timor-Leste", "TL", "TLS", "ISO 3166-2:TL", "Asia", "South-eastern Asia", nil
    put_country "Togo", "TG", "TGO", "ISO 3166-2:TG", "Africa", "Sub-Saharan Africa", "Western Africa"
    put_country "Tokelau", "TK", "TKL", "ISO 3166-2:TK", "Oceania", "Polynesia", nil
    put_country "Tonga", "TO", "TON", "ISO 3166-2:TO", "Oceania", "Polynesia", nil
    put_country "Trinidad and Tobago", "TT", "TTO", "ISO 3166-2:TT", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Tunisia", "TN", "TUN", "ISO 3166-2:TN", "Africa", "Northern Africa", nil
    put_country "Turkey", "TR", "TUR", "ISO 3166-2:TR", "Asia", "Western Asia", nil
    put_country "Turkmenistan", "TM", "TKM", "ISO 3166-2:TM", "Asia", "Central Asia", nil
    put_country "Turks and Caicos Islands", "TC", "TCA", "ISO 3166-2:TC", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Tuvalu", "TV", "TUV", "ISO 3166-2:TV", "Oceania", "Polynesia", nil
    put_country "Uganda", "UG", "UGA", "ISO 3166-2:UG", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Ukraine", "UA", "UKR", "ISO 3166-2:UA", "Europe", "Eastern Europe", nil
    put_country "United Arab Emirates", "AE", "ARE", "ISO 3166-2:AE", "Asia", "Western Asia", nil
    put_country "United Kingdom of Great Britain and Northern Ireland", "GB", "GBR", "ISO 3166-2:GB", "Europe", "Northern Europe", nil
    put_country "United States Minor Outlying Islands", "UM", "UMI", "ISO 3166-2:UM", "Oceania", "Micronesia", nil
    put_country "United States of America", "US", "USA", "ISO 3166-2:US", "Americas", "Northern America", nil
    put_country "Uruguay", "UY", "URY", "ISO 3166-2:UY", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Uzbekistan", "UZ", "UZB", "ISO 3166-2:UZ", "Asia", "Central Asia", nil
    put_country "Vanuatu", "VU", "VUT", "ISO 3166-2:VU", "Oceania", "Melanesia", nil
    put_country "Venezuela (Bolivarian Republic of)", "VE", "VEN", "ISO 3166-2:VE", "Americas", "Latin America and the Caribbean", "South America"
    put_country "Viet Nam", "VN", "VNM", "ISO 3166-2:VN", "Asia", "South-eastern Asia", nil
    put_country "Virgin Islands (British)", "VG", "VGB", "ISO 3166-2:VG", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Virgin Islands (U.S.)", "VI", "VIR", "ISO 3166-2:VI", "Americas", "Latin America and the Caribbean", "Caribbean"
    put_country "Wallis and Futuna", "WF", "WLF", "ISO 3166-2:WF", "Oceania", "Polynesia", nil
    put_country "Western Sahara", "EH", "ESH", "ISO 3166-2:EH", "Africa", "Northern Africa", nil
    put_country "Yemen", "YE", "YEM", "ISO 3166-2:YE", "Asia", "Western Asia", nil
    put_country "Zambia", "ZM", "ZMB", "ISO 3166-2:ZM", "Africa", "Sub-Saharan Africa", "Eastern Africa"
    put_country "Zimbabwe", "ZW", "ZWE", "ISO 3166-2:ZW", "Africa", "Sub-Saharan Africa", "Eastern Africa"

    Mix.shell().info("== Finished synchronizing countries")
  end
end
