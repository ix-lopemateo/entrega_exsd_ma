library(httr)
library(jsonlite)

endpoint <- "http://localhost:3040/blazegraph/namespace/ma/sparql"

ejecutar_consulta <- function(endpoint, query) {
  r <- GET(
    url = endpoint,
    query = list(query = query),
    add_headers(Accept = "application/sparql-results+json")
  )
  
  if (status_code(r) != 200) {
    stop("Error en la consulta SPARQL")
  }
  
  json <- fromJSON(content(r, "text", encoding = "UTF-8"))
  bindings <- json$results$bindings
  
  if (length(bindings) == 0) {
    return(data.frame())
  }
  
  as.data.frame(lapply(bindings, function(x) x$value), stringsAsFactors = FALSE)
}


query1 <- "
PREFIX ma_r: <http://maternal-infant-adiposity.um.es/resource/>
PREFIX ro: <http://purl.obolibrary.org/obo/RO_>

SELECT DISTINCT ?microbe ?metabolite
WHERE {
  ?microbe a ma_r:Microbiota .
  ?microbe ro:0003000 ?metabolite .
}
ORDER BY ?microbe
"

results_q1 <- ejecutar_consulta(endpoint, query1)
View(results_q1)


query2 <- "
PREFIX ma_r: <http://maternal-infant-adiposity.um.es/resource/>
PREFIX ro:   <http://purl.obolibrary.org/obo/RO_>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?metabolite ?metaboliteClass ?epigeneticProcess
WHERE {
  ?metabolite a ?metaboliteClass .
  ?metaboliteClass rdfs:subClassOf ma_r:Metabolite .
  ?metabolite ro:0002213|ro:0002212 ?epigeneticProcess .
}
ORDER BY ?metaboliteClass
"

results_q2 <- ejecutar_consulta(endpoint, query2)
View(results_q2)


query3 <- "
PREFIX ma_r: <http://maternal-infant-adiposity.um.es/resource/>
PREFIX ro: <http://purl.obolibrary.org/obo/RO_>

SELECT DISTINCT ?epigeneticProcess ?lifeStage
WHERE {
  ?epigeneticProcess a ma_r:EpigeneticProcess .
  ?epigeneticProcess ro:0002092 ?lifeStage .
}
ORDER BY ?lifeStage
"

results_q3 <- ejecutar_consulta(endpoint, query3)
View(results_q3)


query4 <- "
PREFIX ma_r: <http://maternal-infant-adiposity.um.es/resource/>
PREFIX ro:   <http://purl.obolibrary.org/obo/RO_>

SELECT DISTINCT ?maternalEntity ?relation ?infantEntity ?lifeStage
WHERE {
  ?maternalEntity ?relation ?infantEntity .
  FILTER (?relation = ro:0002410)

  OPTIONAL { ?maternalEntity ro:0002092 ?lifeStage . }
}
ORDER BY ?lifeStage
"

results_q4 <- ejecutar_consulta(endpoint, query4)
View(results_q4)


query5 <- "
PREFIX ma_r: <http://maternal-infant-adiposity.um.es/resource/>
PREFIX ro:   <http://purl.obolibrary.org/obo/RO_>

SELECT DISTINCT ?metabolite ?epigeneticProcess ?intermediatePhenotype ?finalPhenotype
WHERE {
  ?metabolite ro:0002213|ro:0002212 ?epigeneticProcess .
  ?epigeneticProcess ro:0002213 ?intermediatePhenotype .
  ?intermediatePhenotype ro:0002213 ?finalPhenotype .

  FILTER (?finalPhenotype IN (
    ma_r:Obesity,
    ma_r:ChildhoodObesity
  ))
}
ORDER BY ?finalPhenotype
"

results_q5 <- ejecutar_consulta(endpoint, query5)
View(results_q5)


write.csv(results_q1, "consulta1_microbiota_metabolitos.csv", row.names = FALSE)
write.csv(results_q2, "consulta2_metabolitos_epigenetica.csv", row.names = FALSE)
write.csv(results_q3, "consulta3_epigenetica_etapas.csv", row.names = FALSE)
write.csv(results_q4, "consulta4_transmision.csv", row.names = FALSE)
write.csv(results_q5, "consulta5_rutas_completas.csv", row.names = FALSE)
