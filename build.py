"""src.html + geo.json + cities2.json -> index.html"""
s=open('src.html',encoding='utf-8').read()
s=s.replace('>GEO<','>'+open('geo.json',encoding='utf-8').read()+'<').replace('>CITIES<','>'+open('cities2.json',encoding='utf-8').read()+'<')
open('index.html','w',encoding='utf-8').write(s)
