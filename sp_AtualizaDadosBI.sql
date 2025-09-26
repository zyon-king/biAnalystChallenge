-- =======

-- Tabelas

-- =======



-- Tabela histCasosTrabalhados

CREATE TABLE dbo.histCasosTrabalhados (

    Id_Caso BIGINT,

    País NVARCHAR(255),

    Canal_Entrada NVARCHAR(255),

    Status NVARCHAR(100),

    Resolução NVARCHAR(50),

    Motivo_Chamador NVARCHAR(MAX),

    NomeAgen NVARCHAR(255),

    NomeSupe NVARCHAR(255),

    Data_Hora_Criação DATETIME2(3),

    Data_Hora_Atualização DATETIME2(3),

    Data_Hora_Fechamento DATETIME2(3)

);



-- =======================

-- Verificar data inicial 

-- e data final da base

-- =======================



-- Para encontrar a data de início (a primeira data):

SELECT MIN(CAST(Data_Hora_Criação AS DATE)) AS PrimeiraData

FROM histCasosTrabalhados;



-- Para encontrar a data de fim (a última data):

SELECT MAX(CAST(Data_Hora_Criação AS DATE)) AS UltimaData

FROM histCasosTrabalhados;



-- Dimensão de Colaboradores (Hierárquica)

IF OBJECT_ID('dimColaborador', 'U') IS NULL

CREATE TABLE dimColaborador (

    ID_Colaborador INT PRIMARY KEY IDENTITY(1,1),

    Nome_Colaborador VARCHAR(255) UNIQUE NOT NULL,

    ID_Gestor INT NULL, -- Chave que aponta para o gestor na mesma tabela

    DataCriacao DATETIME2 DEFAULT GETDATE(),

    DataAtualizacao DATETIME2 DEFAULT GETDATE()

);



-- Dimensão de País

IF OBJECT_ID('dimPais', 'U') IS NULL

CREATE TABLE dimPais (

    ID_Pais INT PRIMARY KEY IDENTITY(1,1),

    Pais VARCHAR(255) UNIQUE NOT NULL,

    DataCriacao DATETIME2 DEFAULT GETDATE(),

    DataAtualizacao DATETIME2 DEFAULT GETDATE()

);



-- Dimensão de Canal de Entrada

IF OBJECT_ID('dimCanalEntrada', 'U') IS NULL

CREATE TABLE dimCanalEntrada (

    ID_CanalEntrada INT PRIMARY KEY IDENTITY(1,1),

    Canal_Entrada VARCHAR(255) UNIQUE NOT NULL,

    DataCriacao DATETIME2 DEFAULT GETDATE(),

    DataAtualizacao DATETIME2 DEFAULT GETDATE()

);



-- Dimensão de Status

IF OBJECT_ID('dimStatus', 'U') IS NULL

CREATE TABLE dimStatus (

    ID_Status INT PRIMARY KEY IDENTITY(1,1),

    Status VARCHAR(255) UNIQUE NOT NULL,

    DataCriacao DATETIME2 DEFAULT GETDATE(),

    DataAtualizacao DATETIME2 DEFAULT GETDATE()

);



-- Dimensão de Motivo do Chamador

IF OBJECT_ID('dimMotivoChamador', 'U') IS NULL

CREATE TABLE dimMotivoChamador (

    ID_MotivoChamador INT PRIMARY KEY IDENTITY(1,1),

    Motivo_Chamador VARCHAR(255) UNIQUE NOT NULL,

    DataCriacao DATETIME2 DEFAULT GETDATE(),

    DataAtualizacao DATETIME2 DEFAULT GETDATE()

);



-- Dimensão de Tempo (Horas do Dia)

IF OBJECT_ID('dimTempo', 'U') IS NULL

CREATE TABLE dimTempo (

    ID_Tempo INT PRIMARY KEY, -- Será de 0 a 23

    Hora_Do_Dia VARCHAR(20) NOT NULL, -- Ex: "08:00 - 08:59"

    Periodo VARCHAR(20) NOT NULL, -- Ex: "Manhã"

    Turno VARCHAR(20) NOT NULL -- Ex: "Turno 1"

);

GO



-- Popular a dimTempo

IF (SELECT COUNT(*) FROM dimTempo) = 0

BEGIN

    DECLARE @Hora INT = 0;

    WHILE @Hora < 24

    BEGIN

        INSERT INTO dimTempo (ID_Tempo, Hora_Do_Dia, Periodo, Turno)

        VALUES (

            @Hora,

            FORMAT(@Hora, '00') + ':00 - ' + FORMAT(@Hora, '00') + ':59',

            CASE 

                WHEN @Hora BETWEEN 6 AND 11 THEN 'Manhã'

                WHEN @Hora BETWEEN 12 AND 17 THEN 'Tarde'

                WHEN @Hora BETWEEN 18 AND 23 THEN 'Noite'

                ELSE 'Madrugada'

            END,

            CASE 

                WHEN @Hora BETWEEN 7 AND 15 THEN 'Turno 1'

                WHEN @Hora BETWEEN 16 AND 23 THEN 'Turno 2'

                ELSE 'Turno 3'

            END

        );

        SET @Hora = @Hora + 1;

    END;

    PRINT 'Tabela dimTempo populada com 24 horas.';

END;

GO



-- Dimensão de SLA (Performance Relativa)

IF OBJECT_ID('dimSLA', 'U') IS NULL

CREATE TABLE dimSLA (

    ID_SLA INT PRIMARY KEY,

    Status_SLA VARCHAR(50) NOT NULL,

    Descricao VARCHAR(255)

);

GO



-- Popular a dimSLA

IF (SELECT COUNT(*) FROM dimSLA) = 0

BEGIN

    INSERT INTO dimSLA (ID_SLA, Status_SLA, Descricao) VALUES 

    (1, 'Dentro da Média', 'Caso resolvido em tempo igual ou inferior à média da operação'),

    (2, 'Acima da Média', 'Caso resolvido em tempo superior à média da operação'),

    (-1, 'Não Aplicável', 'Caso ainda não fechado ou com dados insuficientes');

    PRINT 'Tabela dimSLA populada.';

END;

GO



-- =========================

-- Criar Tabela Fato

-- =========================

IF OBJECT_ID('fatoCasos', 'U') IS NOT NULL

DROP TABLE fatoCasos;

GO



-- Ttabela fatoCasos com PRIMARY KEY expandida

CREATE TABLE fatoCasos (

-- Chaves estrangeiras para as dimensões

ID_Calendario INT NOT NULL,

ID_Colaborador INT NOT NULL,

ID_MotivoChamador INT NOT NULL,

ID_Status INT NOT NULL,

ID_CanalEntrada INT NOT NULL,

ID_Pais INT NOT NULL,

            

-- Adicionando as novas chaves de tempo

ID_Tempo_Criacao INT NOT NULL,

ID_Tempo_Atualizacao INT NOT NULL,

ID_Tempo_Fechamento INT NOT NULL,



ID_SLA_Fechamento INT NOT NULL,



-- Métricas e contadores para os KPIs

Qtd_Casos_Abertos INT,

Qtd_Casos_Fechados INT,

Qtd_Resolvido_Sim INT,

Qtd_Resolvido_Nao INT,

Soma_Horas_Para_Atualizacao DECIMAL(18, 2),

Soma_Horas_Para_Fechamento DECIMAL(18, 2),

Qtd_Casos_Com_Atualizacao INT,

Qtd_Casos_Com_Fechamento INT,



-- Chave primária composta ATUALIZADA para incluir a granularidade de tempo

    PRIMARY KEY (

        ID_Calendario, 

        ID_Colaborador, 

        ID_MotivoChamador, 

        ID_Status, 

        ID_CanalEntrada, 

        ID_Pais,

        ID_Tempo_Criacao,

        ID_Tempo_Atualizacao,

        ID_Tempo_Fechamento

    )

);



PRINT 'Tabela fatoCasos recriada com a Primary Key correta.';

GO



-- =============

-- Tabela de log

-- =============

IF OBJECT_ID('ProcessLog', 'U') IS NULL

CREATE TABLE ProcessLog (

    LogID INT IDENTITY(1,1) PRIMARY KEY,

    ProcedureName VARCHAR(100),

    StartTime DATETIME2,

    EndTime DATETIME2,

    Status VARCHAR(20),

    RecordsAffected INT,

    ErrorMessage VARCHAR(MAX)

);



-- ============================

-- Tabela dimCalendario campos 

-- adicionais para BI/Analytics

-- ============================



-- CRIAÇÃO DA TABELA

CREATE TABLE dimCalendario (

    -- Chave primária

    ID_Calendario INT PRIMARY KEY IDENTITY(1,1),

    

    -- Data principal

    Data DATE NOT NULL UNIQUE,

    DataCompleta VARCHAR(10) NOT NULL, -- '2023-12-25'

    

    -- Hierarquia temporal básica

    Ano INT NOT NULL,

    Trimestre INT NOT NULL,

    Bimestre INT NOT NULL,

    Semestre INT NOT NULL,

    SemanaDoAno INT NOT NULL,

    

    -- Detalhes do mês

    Mes INT NOT NULL,

    NomeMes VARCHAR(20) NOT NULL,

    NomeMesCurto VARCHAR(3) NOT NULL, -- 'Jan', 'Fev'

    

    -- Detalhes do dia

    Dia INT NOT NULL,

    DiaDoMes INT NOT NULL,

    DiaDoAno INT NOT NULL,

    DiaDaSemana INT NOT NULL, -- 1=Domingo, 2=Segunda

    NomeDiaSemana VARCHAR(20) NOT NULL,

    NomeDiaSemanaCurto VARCHAR(3) NOT NULL, -- 'Dom', 'Seg'

    

    -- Granularidade adicional

    SemanaDoMes INT NOT NULL,

    QuinzenaDoMes INT NOT NULL, -- 1 ou 2

    

    -- Campos formatados para relatórios

    AnoMes VARCHAR(7) NOT NULL, -- '2023-12'

    AnoTrimestre VARCHAR(7) NOT NULL, -- '2023-Q4'

    AnoSemana VARCHAR(8) NOT NULL, -- '2023-W52'

    AnoSemestre VARCHAR(7) NOT NULL, -- '2023-S2'

    

    -- Flags operacionais

    FlagFimDeSemana BIT NOT NULL,

    FlagDiaUtil BIT NOT NULL,

    FlagFeriado BIT NOT NULL,

    FlagPrimeiroDiaDoMes BIT NOT NULL,

    FlagUltimoDiaDoMes BIT NOT NULL,

    FlagPrimeiroDiaDoAno BIT NOT NULL,

    FlagUltimoDiaDoAno BIT NOT NULL,

    

    -- Informações de feriado

    NomeFeriado VARCHAR(100) NULL,

    TipoFeriado VARCHAR(20) NULL, -- 'Nacional', 'Estadual', 'Municipal'

    

    -- Campos de contexto comparativo

    DataAnterior DATE NOT NULL,

    DataProxima DATE NOT NULL,

    MesmoMesAnoAnterior DATE NOT NULL,

    MesmoDiaAnoAnterior DATE NOT NULL,

    

    -- Período fiscal (opcional - ajustar conforme necessário)

    AnoFiscal INT NULL,

    MesFiscal INT NULL,

    TrimestreFiscal INT NULL,

    

    -- Metadados

    DataCriacao DATETIME2 DEFAULT GETDATE(),

    DataAtualizacao DATETIME2 DEFAULT GETDATE()

);



-- CRIAÇÃO DOS ÍNDICES

CREATE INDEX IX_dimCalendario_Data ON dimCalendario(Data);

CREATE INDEX IX_dimCalendario_AnoMes ON dimCalendario(AnoMes);

CREATE INDEX IX_dimCalendario_Ano_Mes ON dimCalendario(Ano, Mes);

CREATE INDEX IX_dimCalendario_AnoTrimestre ON dimCalendario(AnoTrimestre);

CREATE INDEX IX_dimCalendario_FlagDiaUtil ON dimCalendario(FlagDiaUtil);

CREATE INDEX IX_dimCalendario_FlagFeriado ON dimCalendario(FlagFeriado);

GO



-- PROCEDURE PARA POPULAR A TABELA

CREATE OR ALTER PROCEDURE sp_PopularDimCalendario

    @DataInicio DATE = '2020-01-01',

    @DataFim DATE = '2030-12-31'

AS

BEGIN

    SET NOCOUNT ON;

    

    -- Limpar dados existentes no período

    DELETE FROM dimCalendario 

    WHERE Data BETWEEN @DataInicio AND @DataFim;

    

    -- Variáveis auxiliares

    DECLARE @DataAtual DATE = @DataInicio;

    

    -- Loop principal para inserir as datas

    WHILE @DataAtual <= @DataFim

    BEGIN

        INSERT INTO dimCalendario (

            Data,

            DataCompleta,

            Ano,

            Trimestre,

            Bimestre,

            Semestre,

            SemanaDoAno,

            Mes,

            NomeMes,

            NomeMesCurto,

            Dia,

            DiaDoMes,

            DiaDoAno,

            DiaDaSemana,

            NomeDiaSemana,

            NomeDiaSemanaCurto,

            SemanaDoMes,

            QuinzenaDoMes,

            AnoMes,

            AnoTrimestre,

            AnoSemana,

            AnoSemestre,

            FlagFimDeSemana,

            FlagDiaUtil,

            FlagFeriado,

            FlagPrimeiroDiaDoMes,

            FlagUltimoDiaDoMes,

            FlagPrimeiroDiaDoAno,

            FlagUltimoDiaDoAno,

            NomeFeriado,

            TipoFeriado,

            DataAnterior,

            DataProxima,

            MesmoMesAnoAnterior,

            MesmoDiaAnoAnterior,

            AnoFiscal,

            MesFiscal,

            TrimestreFiscal

        )

        SELECT

            @DataAtual as Data,

            CONVERT(VARCHAR(10), @DataAtual, 23) as DataCompleta,

            YEAR(@DataAtual) as Ano,

            DATEPART(QUARTER, @DataAtual) as Trimestre,

            CASE 

                WHEN MONTH(@DataAtual) IN (1,2) THEN 1

                WHEN MONTH(@DataAtual) IN (3,4) THEN 2

                WHEN MONTH(@DataAtual) IN (5,6) THEN 3

                WHEN MONTH(@DataAtual) IN (7,8) THEN 4

                WHEN MONTH(@DataAtual) IN (9,10) THEN 5

                ELSE 6

            END as Bimestre,

            CASE WHEN MONTH(@DataAtual) <= 6 THEN 1 ELSE 2 END as Semestre,

            DATEPART(WEEK, @DataAtual) as SemanaDoAno,

            MONTH(@DataAtual) as Mes,

            CASE MONTH(@DataAtual)

                WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'

                WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'

                WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'

                WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'

            END as NomeMes,

            CASE MONTH(@DataAtual)

                WHEN 1 THEN 'Jan' WHEN 2 THEN 'Fev' WHEN 3 THEN 'Mar'

                WHEN 4 THEN 'Abr' WHEN 5 THEN 'Mai' WHEN 6 THEN 'Jun'

                WHEN 7 THEN 'Jul' WHEN 8 THEN 'Ago' WHEN 9 THEN 'Set'

                WHEN 10 THEN 'Out' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dez'

            END as NomeMesCurto,

            DAY(@DataAtual) as Dia,

            DAY(@DataAtual) as DiaDoMes,

            DATEPART(DAYOFYEAR, @DataAtual) as DiaDoAno,

            DATEPART(WEEKDAY, @DataAtual) as DiaDaSemana,

            CASE DATEPART(WEEKDAY, @DataAtual)

                WHEN 1 THEN 'Domingo' WHEN 2 THEN 'Segunda-feira' WHEN 3 THEN 'Terça-feira'

                WHEN 4 THEN 'Quarta-feira' WHEN 5 THEN 'Quinta-feira' WHEN 6 THEN 'Sexta-feira'

                WHEN 7 THEN 'Sábado'

            END as NomeDiaSemana,

            CASE DATEPART(WEEKDAY, @DataAtual)

                WHEN 1 THEN 'Dom' WHEN 2 THEN 'Seg' WHEN 3 THEN 'Ter'

                WHEN 4 THEN 'Qua' WHEN 5 THEN 'Qui' WHEN 6 THEN 'Sex'

                WHEN 7 THEN 'Sab'

            END as NomeDiaSemanaCurto,

            CEILING(CAST(DAY(@DataAtual) as FLOAT) / 7) as SemanaDoMes,

            CASE WHEN DAY(@DataAtual) <= 15 THEN 1 ELSE 2 END as QuinzenaDoMes,

            FORMAT(@DataAtual, 'yyyy-MM') as AnoMes,

            CAST(YEAR(@DataAtual) as VARCHAR(4)) + '-Q' + CAST(DATEPART(QUARTER, @DataAtual) as VARCHAR(1)) as AnoTrimestre,

            CAST(YEAR(@DataAtual) as VARCHAR(4)) + '-W' + FORMAT(DATEPART(WEEK, @DataAtual), '00') as AnoSemana,

            CAST(YEAR(@DataAtual) as VARCHAR(4)) + '-S' + CAST(CASE WHEN MONTH(@DataAtual) <= 6 THEN 1 ELSE 2 END as VARCHAR(1)) as AnoSemestre,

            CASE WHEN DATEPART(WEEKDAY, @DataAtual) IN (1, 7) THEN 1 ELSE 0 END as FlagFimDeSemana,

            CASE WHEN DATEPART(WEEKDAY, @DataAtual) BETWEEN 2 AND 6 THEN 1 ELSE 0 END as FlagDiaUtil,

            0 as FlagFeriado, -- Será atualizado posteriormente

            CASE WHEN DAY(@DataAtual) = 1 THEN 1 ELSE 0 END as FlagPrimeiroDiaDoMes,

            CASE WHEN @DataAtual = EOMONTH(@DataAtual) THEN 1 ELSE 0 END as FlagUltimoDiaDoMes,

            CASE WHEN MONTH(@DataAtual) = 1 AND DAY(@DataAtual) = 1 THEN 1 ELSE 0 END as FlagPrimeiroDiaDoAno,

            CASE WHEN MONTH(@DataAtual) = 12 AND DAY(@DataAtual) = 31 THEN 1 ELSE 0 END as FlagUltimoDiaDoAno,

            NULL as NomeFeriado,

            NULL as TipoFeriado,

            DATEADD(DAY, -1, @DataAtual) as DataAnterior,

            DATEADD(DAY, 1, @DataAtual) as DataProxima,

            DATEADD(YEAR, -1, @DataAtual) as MesmoMesAnoAnterior,

            DATEADD(YEAR, -1, @DataAtual) as MesmoDiaAnoAnterior,

            -- Ano fiscal (assumindo que coincide com ano civil)

            YEAR(@DataAtual) as AnoFiscal,

            MONTH(@DataAtual) as MesFiscal,

            DATEPART(QUARTER, @DataAtual) as TrimestreFiscal;

        

        SET @DataAtual = DATEADD(DAY, 1, @DataAtual);

    END;

    

    PRINT 'Dimensão Calendário populada com sucesso de ' + CAST(@DataInicio as VARCHAR(10)) + ' até ' + CAST(@DataFim as VARCHAR(10));

END;

GO



-- PROCEDURE PARA ATUALIZAR FERIADOS BRASILEIROS

CREATE OR ALTER PROCEDURE sp_AtualizarFeriadosBrasileiros

    @Ano INT = NULL

AS

BEGIN

    SET NOCOUNT ON;

    

    IF @Ano IS NULL

        SET @Ano = YEAR(GETDATE());

    

    -- Limpar feriados do ano

    UPDATE dimCalendario 

    SET FlagFeriado = 0, NomeFeriado = NULL, TipoFeriado = NULL

    WHERE Ano = @Ano;

    

    -- Feriados fixos

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Confraternização Universal', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 1 AND Dia = 1;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Tiradentes', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 4 AND Dia = 21;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Dia do Trabalhador', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 5 AND Dia = 1;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Independência do Brasil', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 9 AND Dia = 7;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Nossa Senhora Aparecida', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 10 AND Dia = 12;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Finados', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 11 AND Dia = 2;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Proclamação da República', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 11 AND Dia = 15;

    

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Natal', TipoFeriado = 'Nacional'

    WHERE Ano = @Ano AND Mes = 12 AND Dia = 25;



    -- =======================================================================

    -- CÁLCULO DE FERIADOS MÓVEIS (BASEADO NA PÁSCOA)

    -- Algoritmo de Meeus/Gauss para cálculo do Domingo de Páscoa

    -- =======================================================================

    DECLARE @DataPascoa DATE;

    DECLARE @a INT, @b INT, @c INT, @d INT, @e INT, @f INT, @g INT, @h INT, @i INT, @k INT, @l INT, @m INT;

    DECLARE @MesPascoa INT, @DiaPascoa INT;



    SET @a = @Ano % 19;

    SET @b = @Ano / 100;

    SET @c = @Ano % 100;

    SET @d = @b / 4;

    SET @e = @b % 4;

    SET @f = (@b + 8) / 25;

    SET @g = (@b - @f + 1) / 3;

    SET @h = (19 * @a + @b - @d - @g + 15) % 30;

    SET @i = @c / 4;

    SET @k = @c % 4;

    SET @l = (32 + 2 * @e + 2 * @i - @h - @k) % 7;

    SET @m = (@a + 11 * @h + 22 * @l) / 451;

    

    SET @MesPascoa = (@h + @l - 7 * @m + 114) / 31;

    SET @DiaPascoa = ((@h + @l - 7 * @m + 114) % 31) + 1;

    

    SET @DataPascoa = DATEFROMPARTS(@Ano, @MesPascoa, @DiaPascoa);



    -- =============================================

    -- Atualizar os feriados móveis na dimCalendario

    -- =============================================



    -- Carnaval (Terça-feira, 47 dias antes da Páscoa)

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Carnaval', TipoFeriado = 'Nacional'

    WHERE Data = DATEADD(DAY, -47, @DataPascoa);

    

    -- Sexta-feira Santa (Sexta-feira, 2 dias antes da Páscoa)

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Sexta-feira Santa', TipoFeriado = 'Nacional'

    WHERE Data = DATEADD(DAY, -2, @DataPascoa);



    -- Corpus Christi (Quinta-feira, 60 dias após a Páscoa)

    UPDATE dimCalendario 

    SET FlagFeriado = 1, NomeFeriado = 'Corpus Christi', TipoFeriado = 'Nacional'

    WHERE Data = DATEADD(DAY, 60, @DataPascoa);

    

    -- Atualizar flag de dia útil (remover feriados)

    UPDATE dimCalendario 

    SET FlagDiaUtil = 0

    WHERE Ano = @Ano AND (FlagFimDeSemana = 1 OR FlagFeriado = 1);

    

    PRINT 'Feriados atualizados para o ano ' + CAST(@Ano as VARCHAR(4));

END;

GO



-- EXECUÇÃO INICIAL

-- Popular a tabela com dados de 2020 a 2030

EXEC sp_PopularDimCalendario '2020-01-01', '2030-12-31';



-- Atualizar feriados para os anos principais

DECLARE @AnoAtual INT = 2020;

WHILE @AnoAtual <= 2030

BEGIN

    EXEC sp_AtualizarFeriadosBrasileiros @AnoAtual;

    SET @AnoAtual = @AnoAtual + 1;

END;

GO



-- VIEWS ÚTEIS PARA CONSULTAS FREQUENTES

CREATE OR ALTER VIEW vw_CalendarioCompleto AS

SELECT 

    Data,

    DataCompleta,

    Ano,

    AnoMes,

    AnoTrimestre,

    NomeMes + '/' + CAST(Ano as VARCHAR(4)) as MesAnoExtenso,

    NomeDiaSemana,

    CASE 

        WHEN FlagFeriado = 1 THEN 'Feriado: ' + NomeFeriado

        WHEN FlagFimDeSemana = 1 THEN 'Fim de Semana'

        ELSE 'Dia Útil'

    END as StatusDia,

    FlagDiaUtil,

    FlagFeriado,

    NomeFeriado

FROM dimCalendario;

GO



-- ========================================

--  Criar os registros de "Não Informado" 

-- (com ID -1) em todas as dimensões

-- ========================================



-- Habilita a inserção explícita de identidade psra cada tabela, uma por vez.



-- Dimensão: dimCalendario

SET IDENTITY_INSERT dimCalendario ON;

IF NOT EXISTS (SELECT 1 FROM dimCalendario WHERE ID_Calendario = -1)

    INSERT INTO dimCalendario (

        ID_Calendario, Data, DataCompleta, Ano, Trimestre, Bimestre, Semestre, SemanaDoAno, Mes, NomeMes, NomeMesCurto,

        Dia, DiaDoMes, DiaDoAno, DiaDaSemana, NomeDiaSemana, NomeDiaSemanaCurto, SemanaDoMes, QuinzenaDoMes, AnoMes,

        AnoTrimestre, AnoSemana, AnoSemestre, FlagFimDeSemana, FlagDiaUtil, FlagFeriado, FlagPrimeiroDiaDoMes,

        FlagUltimoDiaDoMes, FlagPrimeiroDiaDoAno, FlagUltimoDiaDoAno, DataAnterior, DataProxima, MesmoMesAnoAnterior,

        MesmoDiaAnoAnterior

    ) VALUES (

        -1, '1900-01-01', '1900-01-01', 1900, 0, 0, 0, 0, 0, 'Não Informado', 'N/I', 0, 0, 0, 0, 'Não Informado',

        'N/I', 0, 0, 'N/I', 'N/I', 'N/I', 'N/I', 0, 0, 0, 0, 0, 0, 0, '1900-01-01', '1900-01-01',

        '1900-01-01', '1900-01-01'

    );

SET IDENTITY_INSERT dimCalendario OFF;



--- Dimensão: dimColaborador

SET IDENTITY_INSERT dimColaborador ON;

IF NOT EXISTS (SELECT 1 FROM dimColaborador WHERE ID_Colaborador = -1)

    INSERT INTO dimColaborador (ID_Colaborador, Nome_Colaborador, ID_Gestor) VALUES (-1, 'Não Informado', NULL);

SET IDENTITY_INSERT dimColaborador OFF;



-- Dimensão: dimTempo

-- Como o ID não é IDENTITY, não é necessáro o SET IDENTITY_INSERT

IF NOT EXISTS (SELECT 1 FROM dimTempo WHERE ID_Tempo = -1)

    INSERT INTO dimTempo (ID_Tempo, Hora_Do_Dia, Periodo, Turno) VALUES (-1, 'Não Informado', 'Não Informado', 'Não Informado');



-- Dimensão: dimMotivoChamador

SET IDENTITY_INSERT dimMotivoChamador ON;

IF NOT EXISTS (SELECT 1 FROM dimMotivoChamador WHERE ID_MotivoChamador = -1)

    INSERT INTO dimMotivoChamador (ID_MotivoChamador, Motivo_Chamador) VALUES (-1, 'Não Informado');

SET IDENTITY_INSERT dimMotivoChamador OFF;



-- Dimensão: dimStatus

SET IDENTITY_INSERT dimStatus ON;

IF NOT EXISTS (SELECT 1 FROM dimStatus WHERE ID_Status = -1)

    INSERT INTO dimStatus (ID_Status, Status) VALUES (-1, 'Não Informado');

SET IDENTITY_INSERT dimStatus OFF;



-- Dimensão: dimCanalEntrada

SET IDENTITY_INSERT dimCanalEntrada ON;

IF NOT EXISTS (SELECT 1 FROM dimCanalEntrada WHERE ID_CanalEntrada = -1)

    INSERT INTO dimCanalEntrada (ID_CanalEntrada, Canal_Entrada) VALUES (-1, 'Não Informado');

SET IDENTITY_INSERT dimCanalEntrada OFF;



-- Dimensão: dimPais

SET IDENTITY_INSERT dimPais ON;

IF NOT EXISTS (SELECT 1 FROM dimPais WHERE ID_Pais = -1)

    INSERT INTO dimPais (ID_Pais, Pais) VALUES (-1, 'Não Informado');

SET IDENTITY_INSERT dimPais OFF;



PRINT 'Registros de "Não Informado" criados com sucesso em todas as dimensões.';

GO



-- ===========================================

--  Adicionar Constraints de Chave Estrangeira

-- ===========================================



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimCalendario

FOREIGN KEY (ID_Calendario) REFERENCES dimCalendario(ID_Calendario);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimColaborador

FOREIGN KEY (ID_Colaborador) REFERENCES dimColaborador(ID_Colaborador);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimTempo_Criacao

FOREIGN KEY (ID_Tempo_Criacao) REFERENCES dimTempo(ID_Tempo);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimTempo_Atualizacao

FOREIGN KEY (ID_Tempo_Atualizacao) REFERENCES dimTempo(ID_Tempo);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimTempo_Fechamento

FOREIGN KEY (ID_Tempo_Fechamento) REFERENCES dimTempo(ID_Tempo);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimMotivoChamador

FOREIGN KEY (ID_MotivoChamador) REFERENCES dimMotivoChamador(ID_MotivoChamador);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimStatus

FOREIGN KEY (ID_Status) REFERENCES dimStatus(ID_Status);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimCanalEntrada

FOREIGN KEY (ID_CanalEntrada) REFERENCES dimCanalEntrada(ID_CanalEntrada);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimPais

FOREIGN KEY (ID_Pais) REFERENCES dimPais(ID_Pais);



ALTER TABLE fatoCasos ADD CONSTRAINT FK_fatoCasos_dimSLA_Fechamento

FOREIGN KEY (ID_SLA_Fechamento) REFERENCES dimSLA(ID_SLA);



PRINT 'Constraints de Chave Estrangeira criadas com sucesso na fatoCasos.';

GO



-- =========================

--  Procedure de Atualização

-- =========================

CREATE OR ALTER PROCEDURE sp_AtualizaDadosBI

AS

BEGIN

    SET NOCOUNT ON;



    DECLARE @LogID INT;

    DECLARE @HistRowCount INT = 0;

    DECLARE @DimRowCount INT = 0;

    DECLARE @FactRowCount INT = 0;



    INSERT INTO dbo.ProcessLog (ProcedureName, StartTime, Status)

    VALUES ('sp_AtualizaDadosBI', GETDATE(), 'In Progress');

    SET @LogID = SCOPE_IDENTITY();



    BEGIN TRY

        BEGIN TRANSACTION;



        -- ===========================

        -- CARREGAR A TABELA HISTÓRICA

        -- ===========================

        TRUNCATE TABLE dbo.histCasosTrabalhados;



        INSERT INTO histCasosTrabalhados (

            Id_Caso, País, Canal_Entrada, Status, Resolução, Motivo_Chamador,

            NomeAgen, NomeSupe, Data_Hora_Criação, Data_Hora_Atualização, Data_Hora_Fechamento

        )

        SELECT

            Id_Caso,

            NULLIF(TRIM(País), ''),

            NULLIF(TRIM(Canal_Entrada), ''),

            NULLIF(UPPER(TRIM(Status)), ''),

            CASE 

                WHEN TRY_CAST(Resolução AS BIT) = 1 THEN 'Yes'

                WHEN TRY_CAST(Resolução AS BIT) = 0 THEN 'No'

                WHEN UPPER(TRIM(CAST(Resolução AS VARCHAR(10)))) IN ('YES', 'SIM', 'TRUE', '1') THEN 'Yes'

                WHEN UPPER(TRIM(CAST(Resolução AS VARCHAR(10)))) IN ('NO', 'NÃO', 'FALSE', '0') THEN 'No'

                ELSE NULL

            END as Resolução,

            NULLIF(TRIM(Motivo_Chamador), ''),

            NULLIF(TRIM(NomeAgen), ''),

            NULLIF(TRIM(NomeSupe), ''),

            COALESCE(TRY_CONVERT(DATETIME, Data_Hora_Criação, 103), TRY_CONVERT(DATETIME, Data_Hora_Criação, 121), TRY_CONVERT(DATETIME, Data_Hora_Criação)) as Data_Hora_Criação,

            COALESCE(TRY_CONVERT(DATETIME, Data_Hora_Atualização, 103), TRY_CONVERT(DATETIME, Data_Hora_Atualização, 121), TRY_CONVERT(DATETIME, Data_Hora_Atualização)) as Data_Hora_Atualização,

            COALESCE(TRY_CONVERT(DATETIME, Data_Hora_Fechamento, 103), TRY_CONVERT(DATETIME, Data_Hora_Fechamento, 121), TRY_CONVERT(DATETIME, Data_Hora_Fechamento)) as Data_Hora_Fechamento

        FROM dbo.baseCasos

        WHERE Id_Caso IS NOT NULL;



        SET @HistRowCount = @@ROWCOUNT;



        -- Etapa 1.5: Calcular o SLA dinâmico (Média de tempo de fechamento em horas)

        DECLARE @AvgHorasFechamento DECIMAL(18, 2);

        SELECT @AvgHorasFechamento = AVG(CAST(DATEDIFF(MINUTE, Data_Hora_Criação, Data_Hora_Fechamento) AS DECIMAL(18, 2)) / 60.0)

        FROM histCasosTrabalhados

        WHERE Data_Hora_Fechamento IS NOT NULL AND Data_Hora_Criação IS NOT NULL;





        -- ================================

        -- ATUALIZAR A DIMENSÃO HIERÁRQUICA

        -- ================================

        -- Etapa 2.1: Inserir todos os colaboradores (agentes e supervisores) que ainda não existem

        INSERT INTO dimColaborador (Nome_Colaborador)

        SELECT DISTINCT Colaborador

        FROM (

            SELECT NomeAgen AS Colaborador FROM histCasosTrabalhados WHERE NomeAgen IS NOT NULL

            UNION

            SELECT NomeSupe AS Colaborador FROM histCasosTrabalhados WHERE NomeSupe IS NOT NULL

        ) AS TodosOsColaboradores

        WHERE NOT EXISTS (SELECT 1 FROM dimColaborador WHERE Nome_Colaborador = TodosOsColaboradores.Colaborador);



        SET @DimRowCount = @@ROWCOUNT; -- Captura apenas os novos membros inseridos



        -- Etapa 2.2: Atualizar a coluna ID_Gestor para definir a hierarquia

        UPDATE Agente

        SET Agente.ID_Gestor = Supervisor.ID_Colaborador

        FROM dimColaborador AS Agente

        INNER JOIN histCasosTrabalhados h ON Agente.Nome_Colaborador = h.NomeAgen

        INNER JOIN dimColaborador AS Supervisor ON Supervisor.Nome_Colaborador = h.NomeSupe

        WHERE Agente.ID_Gestor IS NULL OR Agente.ID_Gestor != Supervisor.ID_Colaborador; -- Atualiza apenas se for nulo ou diferente

        

        INSERT INTO dimMotivoChamador (Motivo_Chamador) SELECT DISTINCT h.Motivo_Chamador FROM histCasosTrabalhados h WHERE h.Motivo_Chamador IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dimMotivoChamador d WHERE d.Motivo_Chamador = h.Motivo_Chamador);

        SET @DimRowCount = @DimRowCount + @@ROWCOUNT;

        

        INSERT INTO dimStatus (Status) SELECT DISTINCT h.Status FROM histCasosTrabalhados h WHERE h.Status IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dimStatus d WHERE d.Status = h.Status);

        SET @DimRowCount = @DimRowCount + @@ROWCOUNT;

        

        INSERT INTO dimCanalEntrada (Canal_Entrada) SELECT DISTINCT h.Canal_Entrada FROM histCasosTrabalhados h WHERE h.Canal_Entrada IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dimCanalEntrada d WHERE d.Canal_Entrada = h.Canal_Entrada);

        SET @DimRowCount = @DimRowCount + @@ROWCOUNT;

        

        INSERT INTO dimPais (Pais) SELECT DISTINCT h.País FROM histCasosTrabalhados h WHERE h.País IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dimPais d WHERE d.Pais = h.País);

        SET @DimRowCount = @DimRowCount + @@ROWCOUNT;



        --- ===================================================

        -- CARREGAR A TABELA FATO (COM HIERARQUIA, TEMPO E SLA)

        -- ====================================================

        TRUNCATE TABLE fatoCasos;



        INSERT INTO fatoCasos (

            ID_Calendario, ID_Colaborador, ID_MotivoChamador, ID_Status, ID_CanalEntrada, ID_Pais,

            ID_Tempo_Criacao, ID_Tempo_Atualizacao, ID_Tempo_Fechamento,

            ID_SLA_Fechamento,

            Qtd_Casos_Abertos, Qtd_Casos_Fechados, Qtd_Resolvido_Sim, Qtd_Resolvido_Nao,

            Soma_Horas_Para_Atualizacao, Soma_Horas_Para_Fechamento, Qtd_Casos_Com_Atualizacao, Qtd_Casos_Com_Fechamento

        )

        SELECT

            COALESCE(cal.ID_Calendario, -1),

            COALESCE(colab.ID_Colaborador, -1),

            COALESCE(mot.ID_MotivoChamador, -1),

            COALESCE(st.ID_Status, -1),

            COALESCE(can.ID_CanalEntrada, -1),

            COALESCE(pais.ID_Pais, -1),

            COALESCE(tempo_cr.ID_Tempo, -1),

            COALESCE(tempo_at.ID_Tempo, -1),

            COALESCE(tempo_fc.ID_Tempo, -1),

            

            -- Classificação do SLA com base na média calculada

            CASE

                WHEN h.Data_Hora_Fechamento IS NULL THEN -1 -- Não Aplicável

                WHEN (CAST(DATEDIFF(MINUTE, h.Data_Hora_Criação, h.Data_Hora_Fechamento) AS DECIMAL(18, 2)) / 60.0) <= @AvgHorasFechamento THEN 1 -- Dentro da Média

                ELSE 2 -- Acima da Média

            END AS ID_SLA_Fechamento,

            

            COUNT(h.Id_Caso) AS Qtd_Casos_Abertos,

            SUM(CASE WHEN h.Status = 'DONE' THEN 1 ELSE 0 END) AS Qtd_Casos_Fechados,

            SUM(CASE WHEN h.Resolução = 'Yes' THEN 1 ELSE 0 END) AS Qtd_Resolvido_Sim,

            SUM(CASE WHEN h.Resolução = 'No' THEN 1 ELSE 0 END) AS Qtd_Resolvido_Nao,

            SUM(CAST(DATEDIFF(MINUTE, h.Data_Hora_Criação, h.Data_Hora_Atualização) AS DECIMAL(18,2)) / 60) AS Soma_Horas_Para_Atualizacao,

            SUM(CAST(DATEDIFF(MINUTE, h.Data_Hora_Criação, h.Data_Hora_Fechamento) AS DECIMAL(18,2)) / 60) AS Soma_Horas_Para_Fechamento,

            COUNT(h.Data_Hora_Atualização) AS Qtd_Casos_Com_Atualizacao,

            COUNT(h.Data_Hora_Fechamento) AS Qtd_Casos_Com_Fechamento

        FROM 

            histCasosTrabalhados h

            LEFT JOIN dimCalendario cal ON cal.Data = CAST(h.Data_Hora_Criação AS DATE)

            LEFT JOIN dimColaborador colab ON colab.Nome_Colaborador = h.NomeAgen

            LEFT JOIN dimMotivoChamador mot ON mot.Motivo_Chamador = h.Motivo_Chamador

            LEFT JOIN dimStatus st ON st.Status = h.Status

            LEFT JOIN dimCanalEntrada can ON can.Canal_Entrada = h.Canal_Entrada

            LEFT JOIN dimPais pais ON pais.Pais = h.País

            LEFT JOIN dimTempo tempo_cr ON tempo_cr.ID_Tempo = DATEPART(HOUR, h.Data_Hora_Criação)

            LEFT JOIN dimTempo tempo_at ON tempo_at.ID_Tempo = DATEPART(HOUR, h.Data_Hora_Atualização)

            LEFT JOIN dimTempo tempo_fc ON tempo_fc.ID_Tempo = DATEPART(HOUR, h.Data_Hora_Fechamento)

        GROUP BY

            cal.ID_Calendario,

            colab.ID_Colaborador,

            mot.ID_MotivoChamador,

            st.ID_Status,

            can.ID_CanalEntrada,

            pais.ID_Pais,

            tempo_cr.ID_Tempo,

            tempo_at.ID_Tempo,

            tempo_fc.ID_Tempo,

            -- O CASE precisa estar no GROUP BY porque não é uma função de agregação

            CASE

                WHEN h.Data_Hora_Fechamento IS NULL THEN -1

                WHEN (CAST(DATEDIFF(MINUTE, h.Data_Hora_Criação, h.Data_Hora_Fechamento) AS DECIMAL(18, 2)) / 60.0) <= @AvgHorasFechamento THEN 1

                ELSE 2

            END;



        SET @FactRowCount = @@ROWCOUNT;

        

        -- =================

        --MENSAGENS E COMMIT

        -- =================

        PRINT '--- Resumo da Execução ---';

        PRINT 'Etapa 1: ' + CAST(@HistRowCount AS VARCHAR(20)) + ' registros inseridos em [histCasosTrabalhados].';

        PRINT 'Etapa 2: ' + CAST(@DimRowCount AS VARCHAR(20)) + ' novos membros inseridos nas tabelas de dimensão.';

        PRINT 'Etapa 3: ' + CAST(@FactRowCount AS VARCHAR(20)) + ' registros de fatos agregados inseridos em [fatoCasos].';

        PRINT '--------------------------';

        PRINT 'Procedure sp_AtualizaDadosBI executada com sucesso.';



        COMMIT TRANSACTION;

        

        UPDATE dbo.ProcessLog

        SET EndTime = GETDATE(), Status = 'Success', RecordsAffected = @FactRowCount

        WHERE LogID = @LogID;



    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0

            ROLLBACK TRANSACTION;

        

        UPDATE dbo.ProcessLog

        SET EndTime = GETDATE(), Status = 'Failure', ErrorMessage = ERROR_MESSAGE()

        WHERE LogID = @LogID;



        PRINT 'ERRO! A transação foi desfeita (ROLLBACK). Verifique a tabela ProcessLog para a mensagem de erro detalhada.';

        THROW;

    END CATCH

END

GO



EXEC sp_AtualizaDadosBI;



GO

SELECT TOP 10 * FROM dimColaborador; 
