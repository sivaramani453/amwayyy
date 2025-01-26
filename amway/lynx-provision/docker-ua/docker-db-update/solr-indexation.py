#! /usr/bin/python3

import requests
import time
import asyncio
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor
requests.packages.urllib3.disable_warnings()

page_url = "https://localhost:9002/hac"

# "ContentIndex" - hanged hybris
MAIN_INDEX_TYPES = ["Index", "CategoryIndex"]
SUP_INDEX_TYPES = [ "AcademyIndex", "LynxNewsIndex", "MediaIndex", "PersonalRetailWebsiteIndex", "VideoIndex"]
RI1_COUNTRY_CODS = ["lynxfin", "lynxswe", "lynxdnk", "lynxnor"]
RI2_COUNTRY_CODS = ["lynxbel", "lynxnld", "lynxesp", "lynxprt"]
RI3_COUNTRY_CODS = ["lynxita", "lynxdeu", "lynxaut", "lynxfra", "lynxche", "lynxgbr", "lynxirl", "lynxgrc"]

def get_hybris_token(hac_url):

   s = requests.Session()
   page = s.get(hac_url, verify=False, allow_redirects=True)
   soup = BeautifulSoup(page.text, "html.parser")
   
   form = soup.find("form")
   field = form.find("input", attrs={"name": "_csrf"})
   token = field.get("value")

   form_data = {
      "j_username": "admin",
      "j_password": "nimda",
      "_csrf": token
   }

   # make login into the hybris admin console
   res = s.post( hac_url + "/j_spring_security_check", data=form_data, verify=False, allow_redirects=False)

   if res.status_code == 302:
      jar = res.cookies
      redirect_url = res.headers["Location"]
      res2 = s.get(redirect_url, cookies=jar)
    
   # get actual csrf token and cookie 
   # after redirect form login page /hac/j_spring_security_check
   # otherwise it won't work
   cookie = res.cookies["JSESSIONID"]

   soup2 = BeautifulSoup(res2.text, "html.parser")
   head = soup2.find("meta", attrs={"name": "_csrf"})
   token2 = head.get("content")

   print("X-CSFR Token: {}, Cookie: JSESSIONID: {}".format(token2, cookie))

   return token2, cookie


def get_indexation_status(hybris_token, session_id, hac_url, index_name):

   headers = {
      "X-CSRF-Token": hybris_token,
      "Cookie": "JSESSIONID="+session_id
   } 
   
   script = "import static de.hybris.platform.solrfacetsearch.enums.IndexerOperationValues.FULL\n" \
   "def config = solrFacetSearchConfigDao.findFacetSearchConfigByName(\'"+index_name+"\')\n" \
   "lynxSetupSolrIndexerService.getSolrIndexerJob(modelService.getSource(config), FULL)?.status?.code"

 
   payload = {
         "script": script,
         "scriptType": "groovy",
         "commit": "true"
   }
    
   url = hac_url + "/console/scripting/execute?j_username=admin&j_password=nimda"
   s = requests.Session()
   res = s.post(url, headers=headers, data=payload, verify=False)
   exec_res = res.json()

   print("Execution results: {}, for index: {}".format(exec_res["executionResult"], index_name))
   print("Stacktrace: {}".format(exec_res["stacktraceText"]))



def launch_solr_indexation(hybris_token, session_id, hac_url, index_name):

   headers = {
      "X-CSRF-Token": hybris_token,
      "Cookie": "JSESSIONID="+session_id
   } 

   payload = {
      "script": "lynxSetupSolrIndexerService.executeSolrIndexerCronJob(solrFacetSearchConfigDao.findFacetSearchConfigByName(\'"+index_name+"\'), true)",
      "scriptType": "groovy",
      "commit": "true"
   } 

   url = hac_url + "/console/scripting/execute?j_username=admin&j_password=nimda"
   s = requests.Session()

   t = time.perf_counter()
   res = s.post(url, headers=headers, data=payload, verify=False)
   elapsed = time.perf_counter() - t
   
   print("Indexation for: {}, executed in {:0.2f} seconds.".format(index_name, elapsed))   
   


async def launch_solr_indexation_asynchronous(url):

   index_list=[]
   for k in [RI1_COUNTRY_CODS, RI2_COUNTRY_CODS, RI3_COUNTRY_CODS]:
      for i in k:
         for j in [MAIN_INDEX_TYPES, SUP_INDEX_TYPES]:
            for l in j:
               index_list.append(i+l)

   token, session = get_hybris_token(url)

   with ThreadPoolExecutor(max_workers=4) as executor:               
      loop = asyncio.get_event_loop()
      tasks = [
         loop.run_in_executor(
            executor,
            launch_solr_indexation,
            *(token, session, url, index)
         )
         for index in index_list
      ]
      for res in await asyncio.gather(*tasks):
         pass

def main_async():
   loop = asyncio.get_event_loop()
   future = asyncio.ensure_future(launch_solr_indexation_asynchronous(page_url))
   loop.run_until_complete(future)

t1 = time.perf_counter()
main_async()
elapsed = time.perf_counter() - t1
print("Executed in {:0.2f} seconds.".format(elapsed))