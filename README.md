# biAnalystChallenge
* Realizar o desafio baseado nas melhores práticas usadas pela área de BI &amp; MIS;
* criando os processos de maneira que fique funcional como se fosse rodar todos os dias;
* após isso, criar o Dashboard como se fosse uma entrega real para o cliente;
* não se limitando apenas as visões solicitadas no desafio.

# Desafio Analista de BI e MIS

## ✅ O QUE É O DESAFIO?

 **Desafio técnico para BI/MIS**, que simula um projeto real. Ele envolve:

1. **Trabalhar com dados** (subir, organizar, tratar e visualizar)
2. **Criar estrutura de banco de dados relacional** (SQL Server)
3. **Automatizar um processo de ETL** (Extract, Transform, Load)
4. **Criar um Dashboard com indicadores de negócio (no Power BI)**

---

## 🧾 O QUE SERÁ ENTREGUE?

Serão **duas entregas principais**:

### 1. **Scripts SQL** (arquivo `.sql` ou `.txt`)
Esses scripts devem conter:
- O comando para **criar e popular a tabela `histCasosTrabalhados`**
- Os comandos para **criar as tabelas dimensões** (`dimCalendario`, `dimFuncionario`, etc.)
- O comando para **criar a tabela fato** com os cálculos exigidos
- A **stored procedure** que atualiza todas as tabelas

> Podendo salvar tudo isso num arquivo chamado, por exemplo:  
`projeto_bi_desafio.sql`

---

### 2. **Dashboard no Power BI** (arquivo `.pbix`)
Com os seguintes indicadores:
- % de resolução
- Total de casos fechados
- Total de casos abertos
- Tempo médio de atualização
- Tempo médio de fechamento
- E outras visões relevantes que o canditado presumir interessante (segmentações por canal, país, data, etc.)

> Salve esse arquivo como:  
`dashboard_casos.pbix`

---

## 📂 ONDE ENTREGAR?

Se o e-mail não indicou uma **plataforma específica** (como Gupy, Kenoby, Revelo, etc.), a entrega pode ser em:

- Resposta ao mesmo e-mail anexando os dois arquivos
- Usar um link de Google Drive ou OneDrive, se os arquivos forem pesados
- Escrever uma explicação simples no corpo do e-mail, como:

> **Assunto:** Entrega Desafio BI & MIS – [Nome]  
> **Corpo do e-mail:**  
> Olá, tudo bem?  
>  
> Segue em anexo a entrega do desafio de BI & MIS:  
> - `projeto_bi_desafio.sql`: scripts de criação e atualização das tabelas no SQL Server  
> - `dashboard_casos.pbix`: dashboard desenvolvido no Power BI  
>  
> Fico à disposição para qualquer dúvida ou esclarecimento.  
>  
> Obrigado pela oportunidade!  
> [Seu Nome]

---

## 🛠️ O QUE É NECESSÁRIO SABER PARA FAZER ISSO?

Aqui está o caminho mais direto para aprender o necessário:

### 1. **SQL Server (Banco de Dados)**
Instalar o SQL Server ou usar o Azure Data Studio (mais leve).
- Aprender a importar CSV no SQL
- Criar tabelas com `CREATE TABLE`
- Inserir dados com `INSERT INTO`
- Criar views e procedures
- Fazer joins para construir tabelas fato

### 2. **Power BI**
- Importar dados de um banco SQL Server
- Criar medidas (`DAX`)
- Criar visuais (gráficos, KPIs)
- Publicar o dashboard (se for pedido)

---
## O Desafio  

### 1. Subir a base de dados para o SQL Server
Suba o arquivo **BaseCasos.csv** para o SQL Server. A tabela deve ser nomeada como **[histCasosTrabalhados]**.

**Execução:**

Marcar a caixa na coluna "Permitir Nulos" para todas as linhas (exceto chave primária, Id_Caso), como Status, Canal_Entrada, Resolução, etc. Isso tornará a carga de dados muito mais resistente a falhas por dados em branco.

Após essa etapa, a prática correta será carregar os dados brutos de forma flexível em uma tabela de "stage" ou área de trabalho (como a histCasosTrabalhados) e só depois aplicar as regras de negócio e a limpeza.


### 2. Criar tabelas dimensões
Crie as seguintes tabelas dimensões no SQL Server, com base na tabela **[histCasosTrabalhados]**:

* **[dimCalendario]**: com base na coluna **[Data_Hora_Criação]**.
* **[dimFuncionario]**: com base na coluna **[NomeAgen]**.
* **[dimSupervisor]**: com base na coluna **[NomeSupe]**.
* **[dimMotiChamador]**: com base na coluna **[Motivo_Chamador]**.
* **[dimStatus]**: com base na coluna **[Status]**.
* **[dimCanalEntrada]**: com base na coluna **[Canal_Entrada]**.
* **[dimPais]**: com base na coluna **[País]**.

### 3. Criar tabela fato
Crie uma tabela fato no SQL Server, também com base na tabela **[histCasosTrabalhados]**. Ela deve conter as chaves estrangeiras das dimensões criadas e os campos necessários para calcular os seguintes indicadores:

* **%Resolução**: (soma do total de “Yes” dividido pela soma do total de “Yes” mais “No”).
* **Total de casos fechados**: (com status “Done”).
* **Total de Casos abertos**.
* **Tempo médio para atualização em Horas**.
* **Tempo médio para fechamento em Horas**.

A tabela fato deve ser sumarizada por período (Dia ou intervalo), não sendo necessário incluir o ID do caso.

### 4. Criar uma procedure de atualização
Crie uma stored procedure que atualize automaticamente as tabelas de dimensão e a tabela fato.

### 5. Criar um dashboard no Power BI
Desenvolva um dashboard no Power BI que visualize os indicadores definidos no item 3.
