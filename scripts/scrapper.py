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

  fruit = []

  imgs = soup.find_all('img')
  img = imgs[len(imgs) - 1]

  # Name
  # print(img['alt'])
  fruit.append(str(img['alt']))
  print(str(img['alt']))

  # Scientific name
  # print(soup.find_all('h3')[8].small.text)
  fruit.append(str(soup.find_all('h3')[8].small.text))

  # Image url
  # print(img['src'])
  fruit.append(str(img['src']))

  # type
  # print(soup.find_all('div', {'style':'margin-top:15px;margin-bottom:15px;'})[0].span.text)
  fruit.append(str(soup.find_all('div', {'style':'margin-top:15px;margin-bottom:15px;'})[0].find_all('span')[1].text.strip()))

  doublecal = []
  months = soup.table.tr.next_sibling.find_all('td')
  length = 0
  for m in months:
    doublecal.append(str(m).find('97c740') != -1)
    if (str(m).find('97c740') != -1):
      length = length + 1
  for m in months:
    doublecal.append(str(m).find('97c740') != -1)

  # print(doublecal)

  season_start = 0
  if (doublecal == False):
    for c in doublecal:
      season_start = season_start + 1
      if (c == True):
        break
  else:
    is_off_season = False
    for c in doublecal:
      season_start = season_start + 1
      if (c == False):
        is_off_season = True
      elif (is_off_season == True):
        break

  fruit.append(length)

  if season_start > 12:
    fruit.append(1)
  else:
    fruit.append(season_start)

  # Color
  colors = soup.find_all('div', {'class':'img-thumbnail'})
  # print(re.findall(r'#[A-Fa-f0-9]{6}', str(colors[len(colors) - 1]))[0])
  fruit.append(re.findall(r'#[A-Fa-f0-9]{6}', str(colors[len(colors) - 1]))[0])

  # Text
  parag = []
  h4 = soup.find_all('h4')
  index = 3
  while True:
    try:
      if (index >= len(h4)):
        break

      title = h4[index].text.strip()
      # print("title : " + title)

      if (title.find('Choisir') == -1 and title.find('Conserver') == -1):
        # print("==> continue")
        index = index + 1
        continue

      text = h4[index].next_sibling.next_sibling.text.strip()

      #print("title : " + title)
      #print("text : " + str(text))
      parag.append(title)
      parag.append(str(text))
      index = index + 1

    except ValueError:
      print(ValueError)

  fruit.append(parag)

  dict = {
   "name": fruit[0],
   "scientific": fruit[1],
   "url": fruit[2],
   "category": fruit[3],
   "length": fruit[4],
   "start": fruit[5],
   "color": fruit[6],
   "text": fruit[7],
  }

  # print(json.dumps(dict))

  fruits.append(dict)

print('done')

end = json.dumps(fruits, ensure_ascii=False)

# print(end)

result_file = open("results.txt", "w")
result_file.write(end)

result_file.close()
