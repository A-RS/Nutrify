import requests 
from bs4 import BeautifulSoup
from recipe_scrapers import scrape_me

from googlesearch import search 


# to search 
ingredients = "apple and banana"

query = ingredients + " recipe"

url = ""

for j in search(query, tld="co.in", num=1, stop=10, pause=2):
    url = j
    print(j)
    break

scraper = scrape_me(url, wild_mode=True)

print(scraper.ingredients())