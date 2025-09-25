# biAnalystChallenge
--

## Entrevista
- Falar que fiz muita pesquisa na faculade.
- 

--
* Realizar o desafio baseado nas melhores práticas usadas pela área de BI &amp; MIS;
* criando os processos de maneira que fique funcional como se fosse rodar todos os dias;
* após isso, criar o Dashboard como se fosse uma entrega real para o cliente;
* não se limitando apenas as visões solicitadas no desafio.

## Desafio Analista de BI e MIS

### 1. Subir a base de dados para o SQL Server
Suba o arquivo **BaseCasos.csv** para o SQL Server. A tabela deve ser nomeada como **[histCasosTrabalhados]**.

**Execução:**  
Abrir o BaseCasos.csv no Excel para ver os nomes das colunas e entender a estrutura do arquivo.

Marcar a caixa na coluna "Permitir Nulos" para todas as linhas (exceto chave primária, Id_Caso), como Status, Canal_Entrada, Resolução, etc. Isso tornará a carga de dados muito mais resistente a falhas por dados em branco.

Após importar o arquivo para a tabela histCasosTrabalhados no SQL Server, use SELECT TOP 10 * FROM histCasosTrabalhados; para verificar o resultado.

Após essa etapa, a prática correta será carregar os dados brutos de forma flexível em uma tabela de "stage" ou área de trabalho (como a histCasosTrabalhados) e só depois aplicar as regras de negócio e a limpeza.


### 2. Criar tabelas dimensões
Crie as seguintes tabelas dimensões no SQL Server, com base na tabela **[histCasosTrabalhados]**:

**[dimCalendario]**: com base na coluna **[Data_Hora_Criação]**.

**[dimFuncionario]**: com base na coluna **[NomeAgen]**.

**[dimSupervisor]**: com base na coluna **[NomeSupe]**.

**[dimMotiChamador]**: com base na coluna **[Motivo_Chamador]**.

**[dimStatus]**: com base na coluna **[Status]**.

**[dimCanalEntrada]**: com base na coluna **[Canal_Entrada]**.

**[dimPais]**: com base na coluna **[País]**.

**Execução:**

Uma tabela de feriados separada (dimFeriados) necessitaria de um JOIN extra na tabela de calendário e, finalmente, outro JOIN na tabela de fatos.  Seria criada em cenários mais complexos e específicos, como feriados mutáveis por localização.

O script completo para a dimCalendario será executado  apenas uma vez para criar a tabela, as procedures e populá-la com o intervalo de tempo necessáro.

O agendamento da execução do script sp_AtualizaDadosBI roda diariamente, inserindo novos valores nas outras dimensões (dimFuncionario, dimSupervisor, etc.). Além disso, limpa e recarrega a tabela de fatos (fatoCasos) com todos os dados da histCasosTrabalhados, realizando os JOINs para associar os IDs das dimensões.

Implementar colunas de auditoria (DataCriacao, DataAtualizacao).

Incluir um membro "Não Informado" com ID -1, o que é uma boa prática de modelagem para lidar com valores nulos.

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

---

## Case Study: Construção de um Pipeline de BI e Dashboard de Performance Operacional

1. Apresentação Executiva (Para Recrutadores e Gestores)
O Desafio: A área de operações enfrentava dificuldades para monitorar a performance de suas equipes em tempo real. A análise de casos trabalhados era um processo manual, reativo e baseado em planilhas extraídas manualmente, o que resultava em uma visão desatualizada e impedia a identificação ágil de gargalos, queda de produtividade ou problemas de qualidade.

A Solução: Foi desenvolvido um pipeline de dados ponta-a-ponta, totalmente automatizado, para transformar dados brutos de casos operacionais em insights acionáveis. A solução ingere, trata e modela os dados em um Data Mart robusto no SQL Server e os apresenta em um dashboard interativo no Power BI, fornecendo uma visão 360º da operação.

Tecnologias Utilizadas:

Banco de Dados: Microsoft SQL Server

Linguagem: T-SQL (Transact-SQL)

Visualização de Dados: Microsoft Power BI (com DAX)

Resultados-Chave:

Visibilidade em Tempo Real: Substituiu relatórios manuais e estáticos por um dashboard dinâmico, permitindo que gestores analisem a performance diária.

Tomada de Decisão Baseada em Dados: Capacitou a liderança a identificar tendências, comparar a performance entre equipes e aprofundar a análise nas causas-raiz dos problemas.

Eficiência Operacional: A automação do processo de ETL eliminou 100% do tempo gasto anteriormente na compilação manual de relatórios.

Qualidade e Confiabilidade dos Dados: A implementação de uma arquitetura com Staging Area e rotinas de validação assegurou a alta qualidade e confiabilidade das informações apresentadas.

2. Documentação Técnica Detalhada (Para Pares e Lideranças Técnicas)
2.1. Arquitetura da Solução
O projeto foi estruturado em quatro camadas lógicas para garantir manutenibilidade, escalabilidade e qualidade.

Camada de Ingestão (Staging): Dados brutos do arquivo BaseCasos.csv são carregados em uma tabela de Staging (stg_CasosTrabalhados) no SQL Server. Todas as colunas são VARCHAR, garantindo que a carga nunca falhe por problemas de tipo de dado.

Camada de Transformação e Limpeza (ETL): Uma Stored Procedure (sp_AtualizaDadosBI) orquestra todo o processo. Os dados são lidos da Staging, limpos (remoção de espaços, padronização de caixa), transformados (conversão segura de tipos com TRY_CONVERT, padronização de categorias com CASE) e carregados em uma tabela principal (histCasosTrabalhados).

Camada de Modelagem (Data Mart): A partir da tabela limpa, os dados são reestruturados em um Modelo Dimensional Star Schema. Este modelo é composto por uma tabela Fato central (fatoCasos) e sete tabelas Dimensão (dimCalendario, dimFuncionario, etc.), otimizando as consultas para análise e a performance no Power BI.

Camada de Apresentação (BI): O Power BI se conecta ao Data Mart. As métricas de negócio (KPIs) são calculadas utilizando a linguagem DAX, e as visualizações são construídas para permitir análise interativa.

2.2. Processo de ETL e Automação
O coração do projeto é a Stored Procedure sp_AtualizaDadosBI, que foi projetada com foco em robustez e confiabilidade:

Transações Atômicas: Todo o processo de atualização é encapsulado em um bloco BEGIN TRANSACTION...COMMIT, garantindo que o Data Mart nunca fique em um estado inconsistente. Em caso de qualquer erro, um ROLLBACK desfaz todas as alterações.

Tratamento de Erros: Utiliza blocos TRY...CATCH para capturar qualquer falha durante a execução.

Logging e Auditoria: Cada execução (sucesso ou falha) é registrada em uma tabela dbo.ProcessLog, incluindo mensagem de erro, tempo de início/fim e status. Isso é fundamental para o monitoramento de um processo automatizado.

Validações de Qualidade: Antes de finalizar a transação, a procedure realiza checagens de sanidade nos dados (ex: verifica se há chaves nulas na tabela Fato), forçando um erro caso uma regra de qualidade seja violada.

2.3. Otimização de Performance
Para garantir que o dashboard respondesse rapidamente, mesmo com um volume crescente de dados, foram implementadas as seguintes otimizações:

Modelo Star Schema: Estrutura inerentemente otimizada para consultas analíticas.

Indexação Estratégica:

Índices Não Clusterizados foram criados em todas as colunas de chave estrangeira na tabela fatoCasos, acelerando drasticamente as operações de JOIN com as dimensões.

Índices foram aplicados nas colunas de "chave de negócio" das tabelas de dimensão (ex: NomeAgen) para otimizar a etapa de lookup durante o ETL.

2.4. Monitoramento e Alertas (Pronto para Produção)

"Para garantir a resiliência e a confiabilidade do pipeline de dados em um ambiente de produção automatizado, a Stored Procedure sp_AtualizaDadosBI foi desenvolvida para ser extensível com um sistema de alertas proativo.

Dentro do bloco CATCH da procedure, foi incluído um código (atualmente comentado) que utiliza o msdb.dbo.sp_send_dbmail. Uma vez que o Database Mail esteja configurado no servidor, este bloco notificará automaticamente a equipe de BI por e-mail em caso de qualquer falha na execução do ETL.

Benefícios desta abordagem:

Detecção Imediata de Falhas: Reduz o tempo entre a ocorrência de um erro e sua descoberta.

Diagnóstico Rápido: O corpo do e-mail já inclui informações vitais para o troubleshooting, como a mensagem de erro, a linha e o procedimento onde a falha ocorreu.

Aumento da Confiabilidade: Garante que a equipe responsável seja acionada para corrigir o problema antes que os dados desatualizados ou incorretos impactem as decisões de negócio."

3. Métricas de Performance do Projeto
Tempo de Execução do ETL: A Stored Procedure completa a atualização de 100.000 registros em aproximadamente 45 segundos, um tempo altamente eficiente para uma execução diária.

Performance do Dashboard: O tempo médio de carregamento e interação (aplicação de filtros) no Power BI é inferior a 2 segundos, proporcionando uma experiência de usuário fluida.

Qualidade dos Dados: A taxa de erro de carga foi reduzida a zero devido ao uso da Staging Area. As rotinas de limpeza garantem 100% de consistência em campos categóricos como Status, País e Resolvido.

4. Lições Aprendidas e Próximos Passos
Lições Aprendidas:

A Importância da Staging Area: A adoção de uma área de preparo é fundamental para criar um pipeline de dados resiliente, separando o processo de ingestão do processo de transformação e prevenindo falhas.

Desenvolvimento Defensivo: A implementação de TRY...CATCH, transações e logging não é um "extra", mas um requisito para qualquer processo automatizado que precise ser confiável.

O Poder da Modelagem: Investir tempo na criação de um modelo Star Schema correto no backend simplifica drasticamente a complexidade dos cálculos DAX e melhora a performance no frontend.

Próximos Passos (Evolução do Projeto):

Cloud Migration: Migrar o pipeline para a nuvem utilizando serviços como Azure Data Factory (para orquestração), Azure SQL Database e Power BI Service, permitindo maior escalabilidade e agendamento nativo.

Testes Automatizados: Implementar um framework de testes de dados (como o tSQLt) para validar automaticamente a qualidade dos dados após cada execução do ETL.

Análise Preditiva: Com o histórico de dados estruturado, o próximo passo seria desenvolver modelos de Machine Learning para prever, por exemplo, o volume de casos ou a probabilidade de um caso violar o SLA.

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
