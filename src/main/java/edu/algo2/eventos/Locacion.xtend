package edu.algo2.eventos

import com.fasterxml.jackson.annotation.JsonIgnore
import edu.algo2.eventos.excepciones.ValidacionException
import edu.algo2.repositorio.Entidad
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.commons.model.annotations.TransactionalAndObservable
import org.uqbar.geodds.Point

@Accessors
@TransactionalAndObservable
class Locacion extends Entidad {
	String nombre
	@JsonIgnore
	Point ubicacion
	@JsonIgnore
	Double superficie // en m2
	@JsonIgnore
	val Double espacioPorPersona = 0.8
	new() {
		
	}
	new(String _nombre, double latitud, double longitud, Double _superficie) {
		nombre = _nombre
		ubicacion = new Point(latitud, longitud)
		superficie = _superficie
	}
	
	def distancia(Point punto){
		ubicacion.distance(punto)
	}
	
	def capacidadMaxima() {
		(superficie / espacioPorPersona) as int
	}
	
	override validar() {
		if (nombre === null || nombre == "") {
			throw new ValidacionException("Error en validacion de nombre")
		}
		if (ubicacion === null) {
			throw new ValidacionException("Error en validacion de ubicacion")
		}
	}
	override actualizar(Entidad elemento) {
		val locacionActualizada = elemento as Locacion
		nombre = locacionActualizada.nombre
		ubicacion = locacionActualizada.ubicacion
		superficie = locacionActualizada.superficie ?: superficie
	}
	
	override tieneNombreIdentificador(String nombreIdentificador) {
		nombre.equals(nombreIdentificador)
	}
	
	override tieneValorBusqueda(String valor) {
		nombre.contains(valor)
	}
	
}