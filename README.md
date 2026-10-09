# Auditoria de Frotas — ISI TP1

Trabalho Prático I de Integração de Sistemas de Informação — Engenharia de Sistemas Informáticos, IPCA.

Pipeline KNIME: abastecimentos CSV + catálogo XML + preços API REST JSON → limpeza, joins e cálculos → PostgreSQL, exportações CSV/JSON e Grafana.

## Estrutura
- dados/: fontes simuladas e exportações.
- knime/Pipeline_Auditoria_Frota.knwf: workflow para importação.
- knime/Pipeline_Auditoria_Frota/: workflow de trabalho.
- docker/: Compose, .env local e .env.example.
- grafana/: dashboard JSON.
- sql/queries.sql: consultas SQL.
- relatorio/: documentação académica.

## Pré-requisitos
Docker Desktop com Docker Compose; KNIME Analytics Platform com os nós usados no workflow (PostgreSQL, XML e JSON).

## Iniciar serviços
Antes da primeira execução, copiar docker/.env.example para docker/.env e preencher as palavras-passe. O .env não é incluído no Git.

Executar na pasta docker:
    docker compose up -d
    docker compose ps

PostgreSQL: localhost:5432; base isi_frota; utilizador isi_user.
Grafana: http://localhost:3000; utilizador admin; palavra-passe do .env.
Para parar sem apagar volumes: docker compose down.

## Executar KNIME
1. Importar knime/Pipeline_Auditoria_Frota.knwf.
2. Ajustar caminhos absolutos dos leitores CSV/XML e escritores à pasta local.
3. Configurar PostgreSQL Connector: localhost, porta 5432, base isi_frota, utilizador isi_user e palavra-passe local.
4. Executar fontes e nós dependentes; confirmar 8 registos válidos.
5. Executar DB Writer, CSV Writer e JSON Writer.

## Grafana
1. Criar fonte PostgreSQL com endereço postgres:5432 (na rede Docker), base isi_frota, utilizador isi_user e palavra-passe do .env.
2. Testar ligação e importar o JSON de grafana/.
3. Associar ou ajustar a fonte de dados dos painéis e guardar.

## Transformações
Regex para matrículas; duplicados pelos atributos do abastecimento; remoção de campos obrigatórios em falta; validação de litros, quilómetros e valor positivos. Join por matrícula e Left Outer Join por combustível. Consumo de fábrica deve ser positivo e não nulo.

- preço pago = valor_total / litros;
- consumo real = litros / km_percorridos × 100;
- desvio (%) = (consumo_real - consumo_fabrica) / consumo_fabrica × 100;
- diferença por litro = preco_litro - avg_price_eurs;
- diferença de custo = valor_total - litros × avg_price_eurs.

GroupBy soma litros e custos por marca e combustível.

## Testes e resultados
Casos inválidos: ID 6 (matrícula), ID 9 (litros em falta), ID 11 (duplicado do ID 1), ID 12 (zero quilómetros).
Com estes 12 registos de entrada, saída esperada: 8 válidos; 488,80 €; 3980 km; 219,90 L; consumo global 5,53 L/100 km; 2 desvios superiores a 30%.
Atualizações da API podem alterar diferenças de custo.

## Referência de mercado
https://api.apiaberta.pt/v1/fuel/prices
Gasóleo simples e gasolina simples 95; data_referencia_api guarda a data da cotação.
Os abastecimentos são simulados e comparados com a média nacional recolhida, não com o preço histórico do dia. Diferenças positivas indicam custo acima da referência, negativas abaixo; não comprovam fraude ou poupança disponível.
O limiar de 30% sinaliza análise. BMW 330e é híbrido: utilização elétrica influencia consumo.

## Git
.env e knime/.metadata/ estão ignorados. Não publicar credenciais, incluindo as guardadas nos workflows. As credenciais anteriormente versionadas continuam no histórico Git.
A imagem Grafana usa latest; fixar a versão utilizada melhora a reprodução.

