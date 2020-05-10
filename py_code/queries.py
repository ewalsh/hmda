import psycopg2 as pg
from config import host, port, dbname, user
import pandas as pd

merge_query = {0: 'select action_taken, applicant_income_000s, applicant_race_name_1, co_applicant_race_name_1, applicant_sex, lien_status, loan_purpose, loan_type, agency_code, owner_occupancy, property_type, purchaser_type_name, hud_median_family_income, loan_amount_000s, number_of_1_to_4_family_units, minority_population, population, tract_to_msamd_income from lar LIMIT 1;'}


def get_query(query: str):
    # connect to # DB
    print("""Establishing Connection""")
    try:
        connection = pg.connect(
            host=host,
            port=port,
            dbname=dbname,
            user=user
        )
        print("""Connection Successful""")
    except Exception: print("""Connection Unsuccessful""")
    cur = connection.cursor()
    cur.execute(query)
    res = cur.fetchall()
    col_names = [desc[0] for desc in cur.description]
    res_df = pd.DataFrame(data=res, columns=col_names)
    connection.close()
    print("""Connection Close""")
    return(res_df)

#
#"select lar.action_taken, lar.applicant_income_000s, lar.applicant_race_name_1, lar.co_applicant_race_name_1, lar.applicant_sex, lar.lien_status, lar.loan_purpose, lar.loan_type, lar.agency_code, lar.owner_occupancy, lar.property_type, lar.purchaser_type_name, lar.hud_median_family_income, lar.loan_amount_000s, lar.number_of_1_to_4_family_units, lar.minority_population, lar.population, lar.tract_to_msamd_income, census.emp, census.estab, census.payann, census.pop, census.county_code, #census.county_name, census.state_code from lar LEFT JOIN census ON lar.county_code = census.county_code AND lar.state_code = 'OH' LIMIT 3"
#
