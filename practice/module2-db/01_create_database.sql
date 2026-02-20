-- ============================================================
-- Модуль 2: Создание базы данных
-- Молочный комбинат "Полесье"
-- Демонстрационный экзамен КОД 09.02.07-5-2026
-- ============================================================

-- Шаг 1: Создать базу данных
CREATE DATABASE DemExam;
GO

USE DemExam;
GO

-- ============================================================
-- Шаг 2: Создать таблицы
-- ============================================================

-- 1. Контрагенты (из Заказчики.json)
CREATE TABLE Контрагенты (
    Id          NVARCHAR(20)  PRIMARY KEY,
    Наименование NVARCHAR(255) NOT NULL,
    ИНН         NVARCHAR(12),
    Адрес       NVARCHAR(255),
    Телефон     NVARCHAR(20),
    Поставщик   BIT           NOT NULL DEFAULT 0,
    Покупатель  BIT           NOT NULL DEFAULT 0
);

-- 2. Номенклатура (продукция и материалы)
CREATE TABLE Номенклатура (
    Код          NVARCHAR(20)  PRIMARY KEY,
    Наименование NVARCHAR(255) NOT NULL,
    ЕдИзм        NVARCHAR(20),
    Тип          NVARCHAR(20)  NOT NULL CHECK (Тип IN (N'Продукция', N'Материал')),
    Цена         DECIMAL(18,2)
);

-- 3. Спецификация (рецептура/BOM)
CREATE TABLE Спецификации (
    Id              INT           PRIMARY KEY IDENTITY(1,1),
    Наименование    NVARCHAR(255) NOT NULL,
    КодПродукции    NVARCHAR(20)  NOT NULL REFERENCES Номенклатура(Код),
    Количество      DECIMAL(18,3) NOT NULL,
    ИзготовительId  NVARCHAR(20)  REFERENCES Контрагенты(Id)
);

-- 4. Строки спецификации
CREATE TABLE СтрокиСпецификации (
    Id              INT           PRIMARY KEY IDENTITY(1,1),
    СпецификацияId  INT           NOT NULL REFERENCES Спецификации(Id),
    КодМатериала    NVARCHAR(20)  NOT NULL REFERENCES Номенклатура(Код),
    Количество      DECIMAL(18,3) NOT NULL
);

-- 5. Заказы покупателей
CREATE TABLE ЗаказыПокупателей (
    Номер          NVARCHAR(20)  PRIMARY KEY,
    Дата           DATE          NOT NULL,
    КонтрагентId   NVARCHAR(20)  NOT NULL REFERENCES Контрагенты(Id),
    ИсполнительId  NVARCHAR(20)  REFERENCES Контрагенты(Id),
    Сумма          DECIMAL(18,2)
);

-- 6. Строки заказов
CREATE TABLE СтрокиЗаказов (
    Id            INT           PRIMARY KEY IDENTITY(1,1),
    ЗаказНомер    NVARCHAR(20)  NOT NULL REFERENCES ЗаказыПокупателей(Номер),
    КодПродукции  NVARCHAR(20)  NOT NULL REFERENCES Номенклатура(Код),
    Количество    DECIMAL(18,3) NOT NULL,
    Цена          DECIMAL(18,2),
    Сумма         DECIMAL(18,2)
);

-- 7. Производство
CREATE TABLE Производство (
    Номер  NVARCHAR(20) PRIMARY KEY,
    Дата   DATE         NOT NULL
);

-- 8. Продукция производства
CREATE TABLE ПродукцияПроизводства (
    Id                  INT           PRIMARY KEY IDENTITY(1,1),
    ПроизводствоНомер   NVARCHAR(20)  NOT NULL REFERENCES Производство(Номер),
    КодПродукции        NVARCHAR(20)  NOT NULL REFERENCES Номенклатура(Код),
    Количество          DECIMAL(18,3) NOT NULL
);

-- 9. Материалы производства
CREATE TABLE МатериалыПроизводства (
    Id                  INT           PRIMARY KEY IDENTITY(1,1),
    ПроизводствоНомер   NVARCHAR(20)  NOT NULL REFERENCES Производство(Номер),
    КодМатериала        NVARCHAR(20)  NOT NULL REFERENCES Номенклатура(Код),
    Количество          DECIMAL(18,3) NOT NULL
);

-- 10. Расчёт стоимости
CREATE TABLE РасчётыСтоимости (
    Id              INT           PRIMARY KEY IDENTITY(1,1),
    КодПродукции    NVARCHAR(20)  NOT NULL REFERENCES Номенклатура(Код),
    СтоимостьИтого  DECIMAL(18,2)
);

-- 11. Строки расчёта стоимости
CREATE TABLE СтрокиРасчёта (
    Id          INT           PRIMARY KEY IDENTITY(1,1),
    РасчётId    INT           NOT NULL REFERENCES РасчётыСтоимости(Id),
    КодМатериала NVARCHAR(20) NOT NULL REFERENCES Номенклатура(Код),
    Количество  DECIMAL(18,3),
    Цена        DECIMAL(18,2),
    Стоимость   DECIMAL(18,2)
);

-- ============================================================
-- Шаг 3: Таблица пользователей (Модуль 4 - авторизация)
-- ============================================================

CREATE TABLE Пользователи (
    Id             INT          PRIMARY KEY IDENTITY(1,1),
    Логин          NVARCHAR(100) NOT NULL UNIQUE,
    Пароль         NVARCHAR(255) NOT NULL,
    Роль           NVARCHAR(50)  NOT NULL DEFAULT N'Пользователь'
                                 CHECK (Роль IN (N'Администратор', N'Пользователь')),
    Заблокирован   BIT           NOT NULL DEFAULT 0,
    НеудачныхПопыток INT         NOT NULL DEFAULT 0
);

-- Тестовые пользователи
INSERT INTO Пользователи (Логин, Пароль, Роль)
VALUES
    (N'admin', N'admin123', N'Администратор'),
    (N'user1', N'pass123',  N'Пользователь');

GO
