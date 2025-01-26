import datetime
import shutil
import os
from collections import namedtuple

EFS_MOUNT_PATH = os.getenv('EFS_MOUNT_PATH')
RETENTION_DAYS = os.getenv('RETENTION_DAYS')

def get_sorted_list_of_folders(subfolders):
   
    unsorted_array = []
    EFSBackup = namedtuple('EFSBackup', 'full_path modif_date')

    for folders in subfolders:
        folder_modification_date = datetime.datetime.fromtimestamp(os.path.getmtime(folders))
        unsorted_array.append(EFSBackup(folders, folder_modification_date))
        sorted_array = sorted(unsorted_array, key=lambda x: getattr(x, 'modif_date'), reverse=False)     


    return sorted_array
   

def clean_old_backups(subfolders):

    current_date = datetime.datetime.now().date()
    list_of_folders = get_sorted_list_of_folders(subfolders)
        
    for element in list_of_folders:
        diff_date = current_date - element.modif_date.date()  
        try:
            if element.full_path == list_of_folders[-1].full_path and diff_date.days>int(RETENTION_DAYS):
                print('Skip deletion of the last backup {}, because it was created: {} days ago'.format(element.full_path, diff_date.days))
            elif diff_date.days>int(RETENTION_DAYS):
                print('Delete backup: {}, Was created {} days ago'.format(element.full_path, diff_date.days))
                shutil.rmtree(element.full_path)
            else:
                print('Valid backup: {}, Created {} days ago'.format(element.full_path, diff_date.days))
        except Exception as e:
            print('Couldn\'t delete old backup: {}. Reason is: {}'.format(element.full_path, e))
            continue 


def lambda_handler(event, lambda_context):
    list_of_subfolders = [ f.path for f in os.scandir(EFS_MOUNT_PATH) if f.is_dir() ]
    clean_old_backups(list_of_subfolders)
