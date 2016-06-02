#sapl_create.py 

### Script a ser rodado com "zopectl run" para criacao de SAPL
### Criado por Ciciliati, em 26/10/2005
### Versao do SAPL: 2.3
### Versao deste script: 1.2 - Gustavo Lepri - 29/10/2008
### Versao atualizada para instalacao de SAPL em Docker: Fabio Rauber (06/2016)

import App.version_txt

versao = App.version_txt.version_txt()

if versao.find('Zope 2.7') > -1:
  t=get_transaction()
else:
  import transaction
  t=transaction.get()

### Criar "sapl"
##### 1 - Configurar ambiente de seguranca
####### 1.1 - Identificar um usuario com perfil 'Manager"
i=0
t_username = ""
l_users=app.acl_users.getUsers()
while i < len(l_users):
    if l_users[i].has_role('Manager'):
        t_username = l_users[i].name
        break
    i=i+1
if not t_username:
    print "*** ERRO! Na foi encontrado um usuário administrador do Zope.Contacte o Interlegis. ***"
######## 1.2 - Registrar esse usuario nesta sessao
from AccessControl.SecurityManagement import newSecurityManager
adminuser=app.acl_users.getUser(t_username).__of__(app.acl_users)
newSecurityManager (None, adminuser)

### Adicionar o SAPL ###
import os;
email = os.getenv('SAPL_EMAIL');
smtp_host = os.getenv('SAPL_SMTP_HOST');
smtp_port = os.getenv('SAPL_SMTP_PORT');
senha = os.getenv('SAPL_PASSWORD');
dbhost = os.getenv('MYSQL_HOST');
dbname = os.getenv('MYSQL_DATABASE');
dbuser = os.getenv('MYSQL_USER');
dbpass = os.getenv('MYSQL_PASSWORD');
nome = os.getenv('SAPL_NAME'); 

nome = nome.decode('utf8').encode('iso-8859-1')
title = "Câmara Municipal de %s" %(nome)
description = "Câmara Municipal de %s: Informações sobre a câmara, o município, parlamentares, leis e processo legislativo com transparência" %(nome)
mp_path = '/'

try:
	app.manage_addProduct['ILSAPL'].manage_addSAPL(id='sapl', title='SAPL - Sistema de Apoio ao Processo Legislativo', database='MySQL')
	sapl = app['sapl']
	sapl.manage_changeProperties(title=title, description=description)
	sapl.sapl_documentos.props_sapl.manage_changeProperties(nom_casa=title, end_email_casa=email)
	sapl.MailHost.manage_makeChanges(title='SMTP Host', smtp_host=smtp_host, smtp_port=smtp_port)
	sapl.acl_users.userFolderAddUser('manager', senha, ['Manager','Owner'],[])
	sapl.acl_users.userFolderEditUser(name='saploper', password=senha, roles=['Operador'], domains='')
	sapl.acl_users.userFolderEditUser(name='sapladm', password=senha, roles=['Administrador'], domains='')
	sapl.manage_delObjects('Members')
	connection_string = "%s@%s %s %s" %(dbname, dbhost, dbuser, dbpass) 
	sapl.dbcon_interlegis.manage_edit(title='Banco de Dados do SAPL (MySQL)', connection_string=connection_string, check=None)


	### Gravar alteracoes
	t.commit()
except:
	print "Erro não esperado ao criar sapl de %s, email %s, senha %s." %(title,email,senha)
	raise 
