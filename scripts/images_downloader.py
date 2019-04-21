import json
import requests
from bs4 import BeautifulSoup
import lxml
import re

file = open("urls.txt", "r")
urls = file.read().split('\n')

fruits = []

for url in urls:
  if (len(url) == 0):
    break

  req = requests.get(url)
  soup = BeautifulSoup(req.text, "lxml")

  imgs = soup.find_all('img')
  img = imgs[len(imgs) - 1]

  image_url = img['src']
  fruit_name = str(img['alt'])

  print(fruit_name)

  image_req = requests.get(image_url)

  save_file = open("images/" + fruit_name + ".jpg", "wb")
  save_file.write(image_req.content)
  save_file.close()

print('Done.')
