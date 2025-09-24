# biAnalystChallenge
* Realizar o desafio baseado nas melhores práticas usadas pela área de BI &amp; MIS;
* Criando os processos de maneira que fique funcional como se fosse rodar todos os dias;
* Após isso, criar o Dashboard como se fosse uma entrega real para o cliente;
* Não se limitando apenas as visões solicitadas no desafio.

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


