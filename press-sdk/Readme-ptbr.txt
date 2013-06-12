PressObjects SDK, Vers�o 0.1.1
Copyright (C) 2006-2007 Laserpress Ltda.

http://www.pressobjects.org

Vide arquivo LICENSE.txt, incluso nesta distribui��o, para detalhes do
copyright.


INTRODU��O
==========

PressObjects � um kit de desenvolvimento de software (SDK) composto por diversos
frameworks que auxiliam a constru��o de aplica��es orientadas a objetos. O
c�digo � compat�vel com os compiladores Delphi-Win32 e Free Pascal.


FRAMEWORKS E RECURSOS
=====================

Apresenta��o de objetos de neg�cio
----------------------------------
Atrav�s do padr�o MVP, objetos de neg�cio s�o apresentados em componentes
visuais simples, tal como TEdit e TComboBox. H� diversas vantagens nesta
abordagem, tal como: separar totalmente as regras de neg�cio e de apresenta��o
da implementa��o do formul�rio; permitir o uso de outros componentes que o
framework n�o conhece; replicar c�digo e comportamento apenas registrando
models, views ou interactors customizados, etc.

Persist�ncia
------------
Objetos de neg�cio s�o lidos e armazenados atrav�s da interface IPressDAO,
que pode ser implementada por uma classe de persist�ncia (OPF) ou um web
service.

Notifica��o
-----------
O framework de notifica��o do PressObjects � baseado no padr�o
publish-subscriber, que � um padr�o mais flex�vel do que o observer. Algumas de
suas caracter�sticas: publicadores e observadores podem ter uma rela��o de
muitos para muitos (NxN); eventos podem ser enfileirados para serem processados
quando a aplica��o entrar em modo de espera; eventos s�o objetos, portanto podem
transportar dados; classes de evento n�o precisam ser declaradas junto com
publicadores, portanto, reduz o acoplamento.

Relat�rios
----------
Todo o metadado das classes de neg�cio s�o transformados em campos e containeres
atrav�s do framework de relat�rios. Desta forma, qualquer formul�rio de consulta
de dados ou qualquer pesquisa pode ser transformada em um relat�rio pelo pr�prio
usu�rio da aplica��o. Tais relat�rios s�o disponibilizados para todos os demais
usu�rios sem que seja necess�rio recompilar ou mesmo fechar e reabrir a
aplica��o.

Modelagem visual (em desenvolvimento)
----------------
Classes de neg�cio, classes MVP, classes para relat�rios entre outras s�o
criadas atrav�s do Project Explorer na IDE. As informa��es s�o gravadas nos
fontes do projeto, desta forma atualiza��es feitas em c�digo s�o vis�veis no
Project Explorer e vice-versa.

Integra��o
----------
Formul�rios conhecem seus objetos de neg�cio, controles visuais conhecem seus
atributos. Desta forma configurar controles complexos, tal como um grid, � uma
quest�o de informar ao controle qual � o atributo ao qual ele se refere. A
partir deste ponto o controle visual estar� apto a encontrar classes de
formul�rios, instanci�-los e apresent�-los sem que seja necess�ria qualquer outra
interven��o do programador.


PRIMEIROS PASSOS
================

Consulte os aplicativos demonstra��o:
($Press)/Demos/Readme.txt
($Press)/Demos/

Visite o wiki do PressObjects:
http://wiki.pressobjects.org


SUPORTE, BUGS, CONTATO
======================

Vide informa��es no site do projeto:
http://br.pressobjects.org
