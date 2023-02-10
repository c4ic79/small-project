#!/usr/bin/env python
# coding: utf-8

# In[3]:


import json
import pandas as pd
import math
import requests
from bs4 import BeautifulSoup
from pandas import DataFrame


# 1 내 정보 조회해보기
# 

# In[4]:


# 개발자 센터에서 발급 받은 API_key
api_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJYLUFwcC1SYXRlLUxpbWl0IjoiNTAwOjEwIiwiYWNjb3VudF9pZCI6IjE1MTAzMzQzNzkiLCJhdXRoX2lkIjoiMiIsImV4cCI6MTY5MTA0ODQ3MiwiaWF0IjoxNjc1NDk2NDcyLCJuYmYiOjE2NzU0OTY0NzIsInNlcnZpY2VfaWQiOiI0MzAwMTE0ODEiLCJ0b2tlbl90eXBlIjoiQWNjZXNzVG9rZW4ifQ.V-hpf3f6IV5MZp7U1WJRj3eup1X_M9a6HA3oW0uOX44'
parameter={'nickname': '딸기맛포도'}
headers= {'Authorization' : api_key}
url1=requests.get('https://api.nexon.co.kr/fifaonline4/v1.0/users?',params=parameter,  headers=headers)
my_json=url1.json()
my_id_data=pd.DataFrame(my_json, index=[0])


# In[5]:


my_id_data # 내 고유식별자와 닉네임, 레벨 정보를 얻을 수 있다.


# 2. 나의 경기 기록 조회해보기

# In[6]:


headers= {'Authorization' : api_key}
#matchtype 50번(순위경기)에 대한 나의 50경기 기록 조회
match_params = {'matchtype' : 50, 'offset' : 0, 'limit' : 50}
url2=requests.get('https://api.nexon.co.kr/fifaonline4/v1.0/users/09a24900ff49b854f39651c9/matches?',params=match_params, headers=headers)
matchid_json=url2.json()
matchid=pd.DataFrame(matchid_json)


# In[7]:


#경기 기록을 가지고 있는 게임ID를 조회
matchid_json[:5]


# 3. matchID를 이용하여 게임 기록을 상세하게 조회해보자
# 

# In[8]:


mygame=pd.DataFrame()

for x, y in enumerate(matchid_json):
    matchid=matchid_json[x]
    url3=requests.get(f'https://api.nexon.co.kr/fifaonline4/v1.0/matches/{matchid}',headers=headers)
    mygame_json=url3.json()
    df=pd.DataFrame(mygame_json)
    mygame=pd.concat([df,mygame],axis=0)
    


# In[9]:


mygame[:1]


# In[10]:


#matchId , matchDate , matchType , matchInfo 등의 열로 존재
#matchInfo는 accessId, nickname, matchDetail, shoot, shootDetail, pass, defence, player가 존재함
#matchid 하나당 두개의 matchInfo가 존재하는데 나의 기록과 나와 게임을 함께한 상대의 기록이다.
#인덱스가 0,1로 묶여있으니 같은 게임끼리는 같은 인덱스를 갖도록 만들어보자


# In[11]:


# 인덱스 변경
idx=list()
for i in range(0,50):
    x=i
    y=i
    idx.append(x)
    idx.append(y)

mygame['index']=idx
mygame=mygame.set_index('index',drop=True)


# matchInfo 전처리
# 
# 

# In[12]:


#matchInfo를 matchInfo에 존재하는 accessId, nickname, matchDetail, shoot, shootDetail, pass, defence, player로 나누어보겠다
#일단 자세한 인게임 내에 데이터는 제외하고 간단하게 승,패 데이터만 분석해보겠다.

accessid=pd.DataFrame([i.get('accessId') for i in mygame['matchInfo']],columns=['accessid'])
nickname=pd.DataFrame([i.get('nickname') for i in mygame['matchInfo']],columns=['nickname'])
matchdetail=pd.DataFrame([i.get('matchDetail') for i in mygame['matchInfo']])
shoot=pd.DataFrame([i.get('shoot') for i in mygame['matchInfo']]) #슈팅 횟수, 유효슛, 골 횟수 등등
shootdetail=pd.DataFrame([i.get('shootDetail') for i in mygame['matchInfo']]) #슈팅시간 , 슈팅좌표,슈팅결과 등등
passlist=pd.DataFrame([i.get('pass') for i in mygame['matchInfo']]) #패스 수 ,패스 성공 수 등등
defence=pd.DataFrame([i.get('defence') for i in mygame['matchInfo']]) #블락, 태클 시도 횟수 등등
player=pd.DataFrame([i.get('player') for i in mygame['matchInfo']]) #선수 고유식별자, 포지션 등등


# 경기 결과 관련 데이터(경기결과, 드리블,평점 등 계산)

# In[13]:


just_result=pd.concat([accessid,nickname,matchdetail],axis=1)
just_result.to_csv('C://Users//Administrator//Desktop//피파4 api//just_result.csv',encoding='utf-8-sig')


# shootdetail 컬럼 전처리!!

# In[14]:


#goaltime

li_1=[]
for i in mygame['matchInfo']:
    shootdetail=i.get('shootDetail')
    for a in shootdetail:
        li_1.append(a.get('goalTime'))

goaltime=pd.DataFrame(li_1)

p=math.pow(2,24)

def cal_goaltime(i):
   
    if (0<i) and (i < p-1): #전반
        return int(i/60)
    elif (p<i) and (i<2*p-1): #후반
        return int((i-p+(45*60))/60)
    elif (2*p<i) and (i<3*p-1): #연장전반
        return int((i-(2*p)+(90*60))/60)
    elif (3*p<i) and (i<4*p-1):  #연장후반
        return int((i-(3*p)+(105*60))/60)
    elif (4*p<i) and (i < 5*p -1): #승부차기
        return int((i-(4*p)+(120*60))/60)
    
    
goaltime=pd.DataFrame(goaltime[0].apply(cal_goaltime))
goaltime.rename(columns={0:"골 시간(분)"},inplace=True)

#x좌표 
li_2=[]
for i in mygame['matchInfo']:
    shootdetail=i.get('shootDetail')
    for a in shootdetail:
        li_2.append(a.get('x'))

coord_x=pd.DataFrame(li_2)
coord_x.rename(columns={0:"x좌표"},inplace=True)

#y좌표 
li_3=[]
for i in mygame['matchInfo']:
    shootdetail=i.get('shootDetail')
    for a in shootdetail:
        li_3.append(a.get('y'))

coord_y=pd.DataFrame(li_3)
coord_y.rename(columns={0:"y좌표"},inplace=True)

#슛타입 
li_4=[]
for i in mygame['matchInfo']:
    shootdetail=i.get('shootDetail')
    for a in shootdetail:
        li_4.append(a.get('type'))

shoot_type=pd.DataFrame(li_4)
shoot_type.rename(columns={0:"슛 종류"},inplace=True)
shoot_type=shoot_type.replace([1,2,3,4,5,6,7,8,9,10],['normal','finesse','head','lob','flare','low','volley','free-kick','penalty','knuckle'])

#슛 결과 
li_5=[]
for i in mygame['matchInfo']:
    shootdetail=i.get('shootDetail')
    for a in shootdetail:
        li_5.append(a.get('result'))

shoot_result=pd.DataFrame(li_5)
shoot_result.rename(columns={0:"슈팅 결과"},inplace=True)
shoot_result=shoot_result.replace([1,2,3],['유효','무효','골'])

    


# In[15]:


df=pd.concat([nickname,player],axis=1)
new_player= df.loc[df['nickname']=='딸기맛포도']
new_player=new_player.drop(['nickname'],axis=1)
new_player=new_player.dropna()


# 선수 정보 데이터 셋(player) 생성하기

# In[16]:


# 인덱스 변경
idx2=list()
for i in range(0,48):
    x=i
    idx2.append(x)
    
new_player['index']=idx2
new_player=new_player.set_index('index',drop=True)


# In[17]:


list_2=[]
for x in range(len(new_player)):
    for y in range(len(new_player[x])):
        list_2.append(new_player[x][y])
    


# player 전처리

# In[18]:


#spid
li_11=[]
for i in list_2:
    li_11.append(i.get('spId'))


spid=pd.DataFrame(li_11)
spid.rename(columns={0:'선수식별자'},inplace=True)

#spposition

li_12=[]
for i in list_2:
    li_12.append(i.get('spPosition'))


sppos=pd.DataFrame(li_12)
sppos.rename(columns={0:'선수포지션'},inplace=True)


#spgrade

li_13=[]
for i in list_2:
    li_13.append(i.get('spGrade'))


spgrade=pd.DataFrame(li_13)
spgrade.rename(columns={0:'선수강화등급'},inplace=True)

#status
li_14=[]
for i in list_2:
    li_14.append(i.get('status'))

status=pd.DataFrame(li_14)
status.rename(columns={0:'선수경기스탯'},inplace=True)


# In[19]:


about_player= pd.concat([spid,sppos,spgrade,status],axis=1)


# In[20]:


about_player[:3]
runner_id=about_player[['선수식별자']]
runner_id.rename(columns={'선수식별자':"id"},inplace=True)


# In[21]:


about_player[:3]


# In[22]:


runner_id.to_csv('C://Users//Administrator//Desktop//피파4 api//runner_id.csv',encoding='utf-8-sig')


# In[62]:


url4=requests.get(f'https://static.api.nexon.co.kr/fifaonline4/latest/spid.json',headers=headers)
runner_json=url4.json()
runner=pd.DataFrame(runner_json)
runner.to_csv('C://Users//Administrator//Desktop//피파4 api//runner.csv',encoding='utf-8-sig')

url5=requests.get(f'https://static.api.nexon.co.kr/fifaonline4/latest/seasonid.json',headers=headers)
sid_json=url5.json()
sid=pd.DataFrame(sid_json)
sid.to_csv('C://Users//Administrator//Desktop//피파4 api//sid.csv',encoding='utf-8-sig')

url6=requests.get(f'https://static.api.nexon.co.kr/fifaonline4/latest/spposition.json',headers=headers)
pos_json=url6.json()
pos=pd.DataFrame(pos_json)
pos.to_csv('C://Users//Administrator//Desktop//피파4 api//sid.csv',encoding='utf-8-sig')
pos.rename(columns={'spposition':'선수포지션'},inplace=True)


# In[63]:


runner[:1]


# In[64]:


runner_id[:1]


# In[65]:


pos[:1]


# In[66]:


player_name=pd.merge(runner_id,runner,left_on='id' ,right_on='id',how='left')
player_name['id']=player_name['id'].astype('str')


# In[67]:


sid['seasonId']=sid['seasonId'].astype('str')


# In[68]:


player_name[:1]


# In[69]:


player_name.info()


# In[70]:


player_name['seasonId']=player_name['id'].str[:3]


# In[71]:


sid[:1]


# In[72]:


player_name_2=pd.merge(player_name,sid,left_on='seasonId',right_on='seasonId',how='left')


# In[73]:


player_name_2=player_name_2.drop(['id_3','seasonImg'],axis=1) #선수이미지 사진 drop함


# In[74]:


player_info=pd.concat([player_name_2,about_player],axis=1)


# In[75]:


player_info=player_info.drop(['선수식별자','seasonImg'],axis=1) #몇 게임을 뛰었는지는 알 수 있지만 어느게임을 어떤선수랑 함께 뛰었는지는 알지못함........


# In[76]:


player_name_3=pd.merge(player_info,pos,left_on='선수포지션',right_on='선수포지션',how='left')


# In[79]:


player_info=player_name_3.drop(['선수포지션'],axis=1)


# In[80]:


player_info[:1]


# In[82]:


player_info.to_csv('C://Users//Administrator//Desktop//피파4 api//player_info.csv',encoding='utf-8-sig')


# 50경기 중 기록되지 않은 2경기를 제외한 48경기에서 선발선수 11명 + 교체명단 선수 7명을 포함한 864개의 데이터

# 패스관련 데이터

# In[59]:


about_pass=pd.concat([nickname,matchdetail[['seasonId','matchResult']],passlist],axis=1)
about_pass.to_csv('C://Users//Administrator//Desktop//피파4 api//about_pass.csv',encoding='utf-8-sig')


# In[72]:


win_pass=about_pass.loc[(about_pass['matchResult']=='승') & (about_pass['nickname']=='딸기맛포도')]
loss_pass=about_pass.loc[(about_pass['matchResult']=='패') & (about_pass['nickname']=='딸기맛포도')]


# 수비 관련 데이터

# In[60]:


about_defence=pd.concat([nickname,matchdetail[['seasonId','matchResult']],defence],axis=1)
about_defence.to_csv('C://Users//Administrator//Desktop//피파4 api//about_defence.csv',encoding='utf-8-sig')

