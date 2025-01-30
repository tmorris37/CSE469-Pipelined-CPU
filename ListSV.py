import os

listSV = os.listdir()

for i in range(0, len(listSV)):
  if (listSV[i][-2] == 's' and listSV[i][-1] == 'v'):
    print(f'vlog "./{listSV[i]}"')