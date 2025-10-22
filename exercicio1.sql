-- CREATE DATABASE BANCOAULA;


--DROP TABLE cliente;
--DROP TABLE apolice;
--DROP TABLE sinistro;
--DROP TABLE carro;


CREATE TABLE cliente (
	cod_cliente int,
	nome varchar(50),
	cpf char(11),
	sexo char(1),
	endereco varchar(200),
	telefone_fixo varchar(10),
	telefone_celular varchar(11),
	CONSTRAINT pk_cliente PRIMARY KEY (cod_cliente)
);


CREATE TABLE apolice (
	cod_apolice int,
	cod_cliente int,
	data_inicio_vigencia date,
	data_fim_vigencia date,
	valor_cobertura numeric(10,2),
	valor_franquia numeric(10, 2),
	placa char(10),
	CONSTRAINT pk_apolice PRIMARY KEY (cod_apolice)
)

CREATE TABLE carro (
	placa char(10),
	modelo varchar(50),
	chassi varchar(30),
	marca varchar(30),
	ano tinyint,
	cor varchar(10),
	CONSTRAINT pk_carro PRIMARY KEY (placa)
	);

CREATE TABLE sinistro (
	cod_sinistro int,
	placa char(10),
	data_sinistro date,
	hora_sinistro time,
	local_sinistro varchar(100),
	condutor varchar(50),
	CONSTRAINT pk_sinistro PRIMARY KEY (cod_sinistro)
);

-- apolice.cod_apolice -> fk_cliente_apolice
ALTER TABLE apolice
ADD CONSTRAINT fk_cliente_apolice FOREIGN KEY (cod_cliente)
REFERENCES cliente (cod_cliente);

-- apolice.cod_apolice -> fk_carro_apolice
ALTER TABLE apolice
ADD CONSTRAINT fk_carro_apolice FOREIGN KEY (placa)
REFERENCES carro (placa);


-- sinistro.cod_sinistro -> fk_carro_sinistro
ALTER TABLE sinistro
ADD CONSTRAINT fk_carro_sinistro FOREIGN KEY (placa)
REFERENCES carro (placa);