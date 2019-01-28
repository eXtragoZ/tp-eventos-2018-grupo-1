package edu.algo2.repositorio

import edu.algo2.eventos.Locacion
import edu.algo2.eventos.Servicio
import edu.algo2.eventos.TarifaFija
import edu.algo2.eventos.TarifaPorHora
import edu.algo2.eventos.TarifaPorPersona
import edu.algo2.eventos.TipoTarifa
import edu.algo2.eventos.TipoUsuarioAmateur
import edu.algo2.eventos.TipoUsuarioFree
import edu.algo2.eventos.TipoUsuarioProfesional
import edu.algo2.eventos.Usuario
import edu.algo2.eventos.excepciones.RepositorioException
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.json.simple.JSONArray
import org.json.simple.JSONObject
import org.json.simple.parser.JSONParser
import org.uqbar.commons.model.annotations.Observable
import org.uqbar.geodds.Point
import org.uqbar.updateService.UpdateService
import edu.algo2.eventos.Evento

@Accessors
abstract class Entidad {
	var static ultimoId = 1
	Integer id

	def void validar()
	def void actualizar(Entidad elemento)
	def boolean tieneNombreIdentificador(String nombreIdentificador)
	def boolean tieneValorBusqueda(String valor)
	
	def esNuevo() {
		id === null
	}
	
	def asignarId() {
		id = ultimoId++
	}
}

abstract class Repositorio<T extends Entidad> {
	val protected static PARSEADOR_JSON = new JSONParser;
	@Accessors val List<T> elementos = newArrayList
	@Accessors UpdateService servicioActualizacion = new UpdateService

	def void create(T elemento) {
		elemento.validar
		elemento.asignarId
		elementos.add(elemento)
	}
	
	def void delete(T elemento) {
		elementos.remove(searchById(elemento.id))
	}
	
	def void update(T elemento) {
		elemento.validar
		searchById(elemento.id).actualizar(elemento)
	}
	
	def T searchById(int _id) {
		val elementoEnRespositorio = elementos.findFirst[id.intValue == _id]
		if (elementoEnRespositorio === null) {
			throw new RepositorioException("No se encontro el id " + _id)
		}
		elementoEnRespositorio
	}
	
	def List<T> search(String value) {
		elementos.filter[tieneValorBusqueda(value)].toList
	}
	
	
	def procesarListaJson(String json) {
		val listaElementosJson = PARSEADOR_JSON.parse(json) as JSONArray
		val List<JSONObject> listadoElementosJson = listaElementosJson.map[it as JSONObject]
		val List<T> listadoElementos = listadoElementosJson.map[procesarElementoJson]
		procesarLista(listadoElementos)
	}
	
	def T procesarElementoJson(JSONObject elementoJson)
	
	def protected buscarId(String nombreIdentificador) {
		elementos.findFirst[tieneNombreIdentificador(nombreIdentificador)]?.id
	}
	
	def protected procesarLista(List<T> listadoElementos) {
		listadoElementos.forEach [
			if (esNuevo) { create } else { update }
		]
	}
	
	def void updateAll() {
		procesarListaJson(obtenerActualizaciones)
	}
	
	def String obtenerActualizaciones()
	
}

@Observable
@Accessors
class RepoUsuarios extends Repositorio<Usuario> {
	
	val static FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");
	val tipoUsuarioFree = new TipoUsuarioFree
	val tipoUsuarioProfesional = new TipoUsuarioProfesional
	val tipoUsuarioAmateur = new TipoUsuarioAmateur
	val tiposUsuarioPosibles = newArrayList => [
		add(tipoUsuarioFree)
		add(tipoUsuarioAmateur)
		add(tipoUsuarioProfesional)
	]
	
	override procesarElementoJson(JSONObject usuarioJson) {
		val direccionJson = usuarioJson.get("direccion") as JSONObject
		val coordenadasJson = direccionJson.get("coordenadas") as JSONObject
		new Usuario => [
			nombreUsuario = usuarioJson.get("nombreUsuario") as String
			nombreApellido = usuarioJson.get("nombreApellido") as String
			email = usuarioJson.get("email") as String
			fechaNacimiento = LocalDate.parse(usuarioJson.get("fechaNacimiento") as String, FORMATO_FECHA)
			direccion = new Point(coordenadasJson.get("x") as Double, coordenadasJson.get("y") as Double)
			id = buscarId(nombreUsuario)
		]
	}
	
	override obtenerActualizaciones(){
		servicioActualizacion.getUserUpdates
	}
	
	override create(Usuario elemento) {
		if (elemento.tipoDeUsuario === null) {
			elemento.tipoDeUsuario = tipoUsuarioFree
		}
		super.create(elemento)
	}
}

@Observable
class RepoLocaciones extends Repositorio<Locacion> {
	override procesarElementoJson(JSONObject locacionJson) {
		new Locacion => [
			nombre = locacionJson.get("nombre") as String
			ubicacion = new Point(locacionJson.get("x") as Double, locacionJson.get("y") as Double)
			superficie = locacionJson.get("superficie") as Double
			id = buscarId(nombre)
		]
	}
	
	override obtenerActualizaciones(){
		servicioActualizacion.getLocationUpdates
	}
}

@Observable
class RepoServicios extends Repositorio<Servicio> {
		
	override procesarElementoJson(JSONObject servicioJson) {
		val tarifaServicioJson = servicioJson.get("tarifaServicio") as JSONObject
		val ubicacionJson = servicioJson.get("ubicacion") as JSONObject
		val tipo = tarifaServicioJson.get("tipo") as String
		var Servicio servicio = new Servicio()
		
		servicio => [
			descripcion = servicioJson.get("descripcion") as String
			tarifa = tarifaServicioJson.get("valor") as Double
			tarifaPorKm = servicioJson.get("tarifaTraslado") as Double
			ubicacion = new Point(ubicacionJson.get("x") as Double, ubicacionJson.get("y") as Double)
			tipoTarifa = seleccionarTipoTarifa(tipo, tarifaServicioJson)
			id = buscarId(descripcion)
		]
	}
	
	def TipoTarifa seleccionarTipoTarifa(String tipo, JSONObject tarifa) {
		if ("TF".equals(tipo)) {
			new TarifaFija
		} else if ("TPP".equals(tipo)) {
			new TarifaPorPersona => [
				porcentajeMinimo = new Double(tarifa.get("porcentajeParaMinimo") as Long) / 100
			]
		} else if ("TPH".equals(tipo)) {
			new TarifaPorHora => [
				costoMinimo = tarifa.get("minimo") as Double
			]
		} else {
			throw new RepositorioException("No existe el tipo de servicio " + tipo)
		}
	}
	
	override obtenerActualizaciones(){
		servicioActualizacion.getServiceUpdates
	}
}

@Observable
class RepoEventos extends Repositorio<Evento> {
	override procesarElementoJson(JSONObject eventoJson) {
		null
	}
	
	override obtenerActualizaciones(){
		"[]"
	}
}