package edu.algo2.eventos

import edu.algo2.eventos.excepciones.ValidacionException
import edu.algo2.repositorio.Entidad
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.commons.model.annotations.TransactionalAndObservable
import org.uqbar.geodds.Point

@Accessors
@TransactionalAndObservable
class Servicio extends Entidad {
	String descripcion
	Double tarifa
	Double tarifaPorKm
	Point ubicacion
	TipoTarifa tipoTarifa

	new() {
		
	}
	
	new(String _descripcion, Point _ubicacion, Double _tarifa) {
		descripcion = _descripcion
		ubicacion = _ubicacion
		tarifa = _tarifa
	}

	def Double costoServicio(Evento evento){
		tipoTarifa.costoServicio(evento,this)
	}

	def costo(Evento evento) {
		costoServicio(evento) + costoTraslado(evento)
	}

	def Double costoTraslado(Evento evento) {
		tarifaPorKm * evento.distancia(ubicacion)
	}
	
	override validar() {
		if (descripcion === null || descripcion == "") {
			throw new ValidacionException("Error en validacion de descripcion")
		}
		if (ubicacion === null) {
			throw new ValidacionException("Error en validacion de ubicacion")
		}
		if (tarifa === null) {
			throw new ValidacionException("Error en validacion de tarifa")
		}
	}
	
	override actualizar(Entidad elemento) {
		val servicioActualizado = elemento as Servicio
		descripcion = servicioActualizado.descripcion
		ubicacion = servicioActualizado.ubicacion
		tarifa = servicioActualizado.tarifa
		tarifaPorKm = servicioActualizado.tarifaPorKm
		tipoTarifa = servicioActualizado.tipoTarifa
	}
	
	override tieneNombreIdentificador(String nombreIdentificador) {
		descripcion.equals(nombreIdentificador)
	}
	
	override tieneValorBusqueda(String valor) {
		descripcion.startsWith(valor)
	}
}

class ServicioMultiple extends Servicio {
	List<Servicio> servicios = newArrayList
	Double porcentajeDescuento = 0.0
	
	new(){
		
	}
	
	new(String _descripcion, Point _ubicacion, Double _tarifa, Double _porcentajeDescuento) {
		super(_descripcion, _ubicacion, _tarifa)
		porcentajeDescuento = _porcentajeDescuento
	}
	
	def agregarServicio(Servicio servicio){
		servicios.add(servicio)
	}
	
	override costo(Evento evento){
		costoServicio(evento) + costoTraslado(evento)
	}
	
	override costoServicio(Evento evento){
		costoSubServicios(evento) * (1-porcentajeDescuento)
	}
	
	def costoSubServicios(Evento evento) {
		servicios.fold(0d, [suma, servicio|suma + servicio.costoServicio(evento)]) 
	}
	
	override costoTraslado(Evento evento){
		servicios.map[costoTraslado(evento)].max
	}
}

interface TipoTarifa {
	def Double costoServicio(Evento evento, Servicio servicio)
}

class TarifaFija implements TipoTarifa {

	override costoServicio(Evento evento, Servicio servicio) {
		servicio.tarifa
	}

	override toString() {
		"Tarifa fija"
	}
}

@Accessors
class TarifaPorHora implements TipoTarifa {

	Double costoMinimo = 0.0

	override costoServicio(Evento evento, Servicio servicio) {
		Double.max(costoMinimo, servicio.tarifa * evento.duracion)
	}
	
	override toString() {
		"Tarifa por hora\nCosto minimo: " + costoMinimo
	}
}

@Accessors
class TarifaPorPersona implements TipoTarifa {

	Double porcentajeMinimo = 1.0

	override costoServicio(Evento evento, Servicio servicio) {
		if(porcentajeMinimo <= evento.porcentajeAsistencia){
			servicio.tarifa * evento.porcentajeAsistencia
		}
		servicio.tarifa * porcentajeMinimo * evento.getCapacidadMaxima
	}
	
	override toString() {
		"Tarifa por Persona\nPorcentaje: " + porcentajeMinimo
	}
}