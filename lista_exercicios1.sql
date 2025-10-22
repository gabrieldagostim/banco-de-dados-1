
-- lista de exercicios 1
-- 1. Quantos clientes cadastrados possuem letra “a” no meio e não no final? (LIKE)
	select count(c.nome) as qtd_nome_clientes from cliente c where c.nome like '%a%';
	go


-- 2. Quantos clientes temos cadastrados da tabela cliente? (COUNT)
	select count(distinct c.nome) as qtd_clientes_unicos from cliente c
	go


--3. Quantos carros possuem a placa iniciando com as letras L ou M? (LIKE)
	select * from carro c where c.placa like 'L%' or c.placa like 'M%'; --quais
	select count(distinct placa) from carro c where c.placa like 'L%' or c.placa like 'M%'; --quantas


--4. Quantos sinistros ocorreram para o carro da placa MZT1826?
	select * from sinistro s where s.placa = 'MZT1826'; -- quais

	select count(placa) as qtd_sinistros_mzt1826 from sinistro s where s.placa = 'MZT1826';

--5. Quantos sinistros ocorreram em 2022? (BETWEEN ou FUNÇÃO YEAR())

	select count(cod_sinistro) as qtd_sinistro 
	from sinistro s 
	where s.data_sinistro between '2022-01-01' and '2022-12-31';

	select count(cod_sinistro) as qtd_sinistro 
	from sinistro s 
	where year(s.data_sinistro) = 2022;

--6. Quantos clientes não possuem telefone fixo E telefone celular cadastrados?
	
	select count(cod_cliente) as clientes_sem_fone from cliente c where c.telefone_celular is null and c.telefone_fixo is null;

--7. Quantos clientes não possuem telefone fixo OU telefone celular cadastrados?

	select count(cod_cliente) as clientes_sem_algum_fone from cliente c where c.telefone_celular is null and c.telefone_fixo is null;

--8. Quantos clientes possuem apólice(s) vencida(s)? Utilize a função GETDATE() para usar como data e hora
--atual.

	select count(cod_cliente) as clientes_apolices_vencidas from apolice a where a.data_fim_vigencia < GETDATE()


--9. Em relação ao modelo abaixo, responda a questão: Quantas regiões existem cadastradas?

	select * from regiao
	select count(cd_regiao) as qtd_regioes_cadastrada from regiao

--10. Quantos estados existem cadastrados?
	select count(e.cd_estado) as qtd_estados_cadastrados from estado e

--11. Quantos municípios existem cadastrados?

	select count(m.cd_municipio) as qtd_municipios_cadastrados from municipio m

--12. Quantos municípios existem na região SUL e que começam com a letra C?


	select * from estado where cd_regiao = 4

	select count(cd_municipio) from municipio where cd_estado in (41,42,43)

--13. Quantos municípios possuem mais de 10 letras no nome? ( função LEN() )

	select count(cd_municipio) as municipios_mais_10_letras from municipio where len(nm_municipio) >10;


--14. Quantos municípios existem na região NORTE?

	select count(cd_municipio) as qtd_municipios_norte from municipio where cd_estado in (11,12,13,14,15,16,17);

--15. Em relação ao modelo abaixo, responda a questão: Quantas avaliações existem cadastradas?

	select count(ds_avaliacao) as qtd_avaliacoes_cadastradas from avaliacao	

--16. Quantos alunos iniciaram e finalizaram suas avaliações? Utilize os campos dt_inicio e dt_fim da tabela
--avaliacao_aluno para elaborar sua consulta.

	select * from avaliacao_aluno where dt_fim is not null


	select distinct count( cd_aluno) from avaliacao_aluno where dt_fim is not null


--17. Quantas questões objetivas possuem as avaliações que começam por “2a” ?
	select distinct count(cd_questao) as qtd_questoes_obj from questao q
	left join avaliacao a
	on  q.cd_avaliacao = a.cd_avaliacao
	where q.tp_questao = 2 and a.ds_avaliacao like '2a%'

--18. Quais são as provas e as questões que possuem mais de 4 alternativas por questão?
	select cd_avaliacao, count(distinct cd_questao) from questao q
	group by cd_avaliacao
	having count(distinct cd_questao) > 4


--19. Existe alguma questão cadastrada do tipo Descritiva? (considere tp_questao = 1 Objetiva,2 Multipla Escolha
--e 3 Descritiva).

	select count(distinct cd_questao) as qtd_questoes_descritivas from questao where tp_questao = 3

