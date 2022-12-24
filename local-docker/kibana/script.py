import requests
import json
import os

endpoint = "http://kibana:5601/"
header = {"kbn-xsrf":"anything","Content-Type": "application/json"}

index_pattern = {}
search = {}
dashboard = {}
visualization = {}

objects = ["index-pattern", "search", "dashboard","visualization"]

for object in objects:
    folder_path = "./" + object
    url = endpoint + "api/kibana/management/saved_objects/_find?perPage=50&page=1&fields=id&type=" + object
    if len(os.listdir(folder_path)) != 0:
        print("Number of %s objects found: %d" % (object, len(os.listdir(folder_path))))
        # Fetch existing objects
        response = requests.get(endpoint + "api/kibana/management/saved_objects/_find?perPage=50&page=1&fields=id&type=" + object)

        if response.status_code == 200:
            response = response.json()
            if response["total"] > 0:
                for id in response["saved_objects"]:
                    if object == "index-pattern":
                        index_pattern[id["meta"]["title"]] = id["id"]
                    elif object == "search":
                        search[id["meta"]["title"]] = id["id"]
                    elif object == "dashboard":
                        dashboard[id["meta"]["title"]] = id["id"]
                    elif object == "visualization":
                        visualization[id["meta"]["title"]] = id["id"]
        else:
            print("Fetch for existing %s failed, check logs: %s" % (object, response.text))


        for filename in os.listdir(folder_path):
            file_details = open(folder_path + "/" + filename,'r')
            file_read = file_details.read()
            file_details.close()
            file_read_dict = json.loads(file_read)   #converts to dict

        if object == "index-pattern":
            dict_object = dict(index_pattern)
        elif object == "search":
            dict_object = dict(search)
        elif object == "dashboard":
            dict_object = dict(dashboard)
        elif object == "visualization":
            dict_object = dict(visualization)

        if len(dict_object) > 0:
            for title in dict_object.keys():
                match = 0

                if title == file_read_dict["attributes"]["title"] and dict_object[title] == file_read_dict["id"]:
                    match = 1
                    file_read_dict.pop('id')
                    file_read_dict.pop('type')
                
                    file_read = json.dumps(file_read_dict)
                    response = requests.post(endpoint + "api/saved_objects/" + object + "/" + dict_object[title] + "?overwrite=true", headers=header, data=file_read)
                    if response.status_code == 200:
                        print("%s %s updated" % (object, title))
                    else:
                        print(response.text)
                elif title == file_read_dict["attributes"]["title"] and dict_object[title] != file_read_dict["id"]:
                    match = 1
                    print("%s title %s matches, but the id's are different, manaual intervention required" % (object, title))
                elif title != file_read_dict["attributes"]["title"] and dict_object[title] == file_read_dict["id"]:
                    match = 1
                    print("%s id %s matches, but the titles are different, manaual intervention required" % (object, dict_object[title]))
            
            if match == 0:
                id = file_read_dict["id"]
                file_read_dict.pop('id')
                file_read_dict.pop('type')
                file_read = json.dumps(file_read_dict)
                response = requests.post(endpoint + "api/saved_objects/" + object + "/" + id, headers=header, data=file_read)
                if response.status_code == 200:
                    print("%s %s created" % (object, title))
                else:
                    print(response.text)
        else:
            id = file_read_dict["id"]
            file_read_dict.pop('id')
            file_read_dict.pop('type')
            file_read = json.dumps(file_read_dict)
            response = requests.post(endpoint + "api/saved_objects/" + object + "/" + id, headers=header, data=file_read)
            if response.status_code == 200:
                print("%s %s created" % (object, file_read_dict["attributes"]["title"]))
            else:
                print(response.text)
        