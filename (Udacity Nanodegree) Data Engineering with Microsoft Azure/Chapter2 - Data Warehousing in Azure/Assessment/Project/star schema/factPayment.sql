--drop Payment table if it exists
BEGIN   
    IF OBJECT_ID('dbo.factPayment') IS NOT NULL
        DROP TABLE factPayment
END    
GO;

--create Payment table structure based on project analytics specifications
CREATE TABLE factPayment (
    PaymentId int NOT NULL,
    RiderId int NOT NULL,
    DateId int NOT NULL,
    Amount smallmoney NOT NULL
)
GO;

--add primary key constraint
ALTER TABLE factPayment
ADD CONSTRAINT PK_factPayment_PaymentId PRIMARY KEY NONCLUSTERED (PaymentId) NOT ENFORCED
GO;

--populate Payment table
INSERT INTO factPayment
SELECT 
    try_convert(int, p.PaymentId),                                                          --convert from bigint to int
    try_convert(int, p.RiderId),                                                            --convert from bigint to int
    try_convert(int, replace(left(p.Date, 10), '-', '')),                                    --convert from text to int
    try_convert(smallmoney, p.Amount)                                                       --convert from float to smallmoney
FROM staging_payment p
    INNER JOIN dimRider r on p.RiderId = r.RiderId                                        --enforce referential integrity
    INNER JOIN dimDate d on try_convert(int, replace(left(p.Date, 10), '-', '')) = d.DateId --enforce referential integrity
GO;

SELECT TOP 100 *
FROM factPayment
GO;