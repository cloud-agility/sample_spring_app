function extractVersions {
   grep 'route' -A999 $1 |tail -n +2 |grep "^[a-zA-Z]\|\'" -B999 |grep version |awk '{print $2}' |tr -d '"'
}

extractVersions $1
