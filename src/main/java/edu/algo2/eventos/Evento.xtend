package edu.algo2.eventos

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonSubTypes
import com.fasterxml.jackson.annotation.JsonTypeInfo
import com.fasterxml.jackson.databind.annotation.JsonDeserialize
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import edu.algo2.eventos.excepciones.EventoException
import edu.algo2.eventos.excepciones.ValidacionException
import edu.algo2.repositorio.Entidad
import edu.algo2.utils.CustomLocalDateTimeDeserializer
import edu.algo2.utils.CustomLocalDateTimeSerializer
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.geodds.Point

@Accessors
@JsonTypeInfo(use=NAME, property="tipo")
@JsonSubTypes(@JsonSubTypes.Type(value=EventoAbierto, name = "Abierto"),
  @JsonSubTypes.Type(value=EventoCerrado, name = "Cerrado"))
abstract class Evento extends Entidad {
	@JsonIgnore
	val List<Servicio> servicios = newArrayList
	String nombre
	@JsonSerialize(using=CustomLocalDateTimeSerializer)
	@JsonDeserialize(using=CustomLocalDateTimeDeserializer)
	LocalDateTime fechaConfirmacion
	@JsonSerialize(using=CustomLocalDateTimeSerializer)
	@JsonDeserialize(using=CustomLocalDateTimeDeserializer)
	LocalDateTime fechaDesde
	@JsonSerialize(using=CustomLocalDateTimeSerializer)
	@JsonDeserialize(using=CustomLocalDateTimeDeserializer)
	LocalDateTime fechaHasta
	Locacion locacion
	boolean cancelado = false
	boolean postergado = false
	Usuario organizador

	new() {
	}

	new(String _nombre, Locacion _locacion) {
		nombre = _nombre
		locacion = _locacion
	}

	def duracion() {
		fechaDesde.until(fechaHasta, ChronoUnit.HOURS)
	}

	def distancia(Point punto) {
		locacion.distancia(punto)
	}

	def Integer getCapacidadMaxima()

	def double porcentajeAsistencia()

	def boolean esExitoso()

	def boolean esUnFracaso()

	def estaActivo() {
		!cancelado && fechaHasta.isAfter(LocalDateTime.now)
	}

	def mismoMes(LocalDateTime fecha) {
		fechaDesde.year == fecha.year && fechaDesde.month == fecha.month
	}

	def mismoMes(Evento evento) {
		mismoMes(evento.fechaDesde)
	}

	def hayTiempoParaConfirmar() {
		fechaConfirmacion.isAfter(LocalDateTime.now)
	}

	def cancelarEvento() {
		notificarCancelacion
		devolverTotalEntradas
		cancelado = true
	}

	def postergarEvento(LocalDateTime nuevaFecha) {
		calcularNuevasFechasPorPostergacion(nuevaFecha)
		notificarPostergacion
		postergado = true
	}

	def void calcularNuevasFechasPorPostergacion(LocalDateTime nuevaFecha) {
		val diferencia = fechaDesde.until(nuevaFecha, ChronoUnit.MINUTES)
		fechaHasta = fechaHasta.plus(diferencia, ChronoUnit.MINUTES)
		fechaConfirmacion = fechaConfirmacion.plus(diferencia, ChronoUnit.MINUTES)
		fechaDesde = nuevaFecha
	}

	def void notificarCancelacion()

	def void notificarPostergacion()

	def void devolverTotalEntradas()

	def mensajeCancelacion() {
		"Se ha cancelado el evento " + nombre
	}

	def mensajePostergacion() {
		"Se ha postergado el evento " + nombre + ' a la nueva fecha de ' + fechaDesde
	}

	def costo() {
		servicios.fold(0d, [suma, servicio|suma + servicio.costo(this)])
	}

	override validar() {
		if (nombre === null || nombre == "") {
			throw new ValidacionException("Error en validacion de nombre")
		}
		if (fechaDesde === null) {
			throw new ValidacionException("Error en validacion de fecha de inicio")
		}
		if (fechaHasta === null) {
			throw new ValidacionException("Error en validacion de fecha de fin")
		}
		if (fechaConfirmacion === null) {
			throw new ValidacionException("Error en validacion de fecha maxima de confirmacion")
		}
		if (locacion === null) {
			throw new ValidacionException("Error en validacion de locacion")
		}
		if (fechaConfirmacion.isAfter(fechaDesde)) {
			throw new ValidacionException(
				"Error en validacion de fecha maxima de confirmacion anterior a fecha de inicio")
		}
		if (fechaDesde.isAfter(fechaHasta)) {
			throw new ValidacionException("Error en validacion de fecha de inicio anterior a fecha de fin")
		}
	}

	def boolean puedeNotificarUsuariosCercanos()

	def List<Artista> artistasParticipantes()

	def int getCantidadEntradasVendidas()

	def int getCantidadInvitaciones()

	override tieneNombreIdentificador(String nombreIdentificador) {
		nombre.equals(nombreIdentificador)
	}

	override tieneValorBusqueda(String valor) {
		nombre.contains(valor)
	}

	override actualizar(Entidad elemento) {
		val eventoActualizado = elemento as Evento
		nombre = eventoActualizado.nombre
	}
	
	def Boolean esAbierto()

}

@Accessors
class EventoAbierto extends Evento {
	var List<Artista> artistasParticipantes = newArrayList

	Double precio = 0d
	int edadMinima = 0
	@JsonIgnore
	val List<Entrada> entradasVendidas = newArrayList

	new() {
		super()
	}

	new(String _nombre, Locacion _locacion) {
		super(_nombre, _locacion)
	}

	override getCapacidadMaxima() {
		locacion.capacidadMaxima()
	}

	override esExitoso() {
		!cancelado && !postergado && porcentajeAsistencia >= 0.9
	}

	override porcentajeAsistencia() {
		cantidadEntradasVendidas as double / capacidadMaxima
	}

	def entradasDisponibles() {
		capacidadMaxima - cantidadEntradasVendidas
	}

	def diasRestantes() {
		LocalDate.now.until(fechaDesde.toLocalDate, ChronoUnit.DAYS)
	}

	def porcentajeDevolucion() {
		Math.min(0.8, 0.1 + diasRestantes * 0.1)
	}

	def valorDevolucion() {
		if(postergado) precio else precio * porcentajeDevolucion
	}

	override esUnFracaso() {
		porcentajeAsistencia < 0.5
	}

	def boolean permiteCompra(Usuario comprador,Integer cantidad) {
		hayEntradasDisponibles(cantidad) && comprador.edad >= edadMinima && hayTiempoParaConfirmar
	}
	
	protected def boolean hayEntradasDisponibles(Integer cantidad) {
		if (entradasDisponibles >= cantidad) return true 
		else throw new EventoException("Entradas agotadas")
	}

	def nuevaEntrada(Usuario comprador) {
		nuevaEntrada(comprador,1)
	}
	
	def nuevaEntrada(Usuario comprador, Integer cantidad) {
		if (permiteCompra(comprador,cantidad)) {
			var entrada = new Entrada(this, comprador, cantidad)
			entradasVendidas.add(entrada)
			comprador.agregarEntrada(entrada)
			comprador.reducirSaldoPorCompra(entrada)
		} else {
			throw new EventoException("No se puede comprar")
		}
	}
	

	override notificarCancelacion() {
		entradasVendidas.forEach[comprador.recibirNotificacion(mensajeCancelacion)]
	}

	override notificarPostergacion() {
		entradasVendidas.forEach[comprador.recibirNotificacion(mensajePostergacion)]

	}

	override devolverTotalEntradas() {
		entradasVendidas.forEach[
			comprador.agregarSaldo(precio * cantidad)
			eliminar
		]
		
	}

	def eliminarEntrada(Entrada entrada) {
		entradasVendidas.remove(entrada)
	}

	override boolean puedeNotificarUsuariosCercanos() {
		true
	}

	override artistasParticipantes() {
		artistasParticipantes
	}

	override getCantidadEntradasVendidas() {
		entradasVendidas.fold(0, [suma, entrada|suma + entrada.cantidad])
	}

	@JsonIgnore
	override getCantidadInvitaciones() {
		0
	}
	
	override esAbierto() {
		return true
	}

}

@Accessors
class EventoCerrado extends Evento {
	@JsonIgnore
	val List<Invitacion> invitaciones = newArrayList
	int capacidadMaxima
	@JsonIgnore
	val List<OrdenDeInvitacion> ordenesDeInvitacion = newArrayList

	new() {
		super()
	}

	new(String _nombre, Locacion _locacion) {
		super(_nombre, _locacion)
	}

	override esExitoso() {
		!cancelado && porcentajeAsistencia >= 0.8 // cambio: era porcentajeConfirmacion
	}

	override getCapacidadMaxima() {
		capacidadMaxima
	}

	override porcentajeAsistencia() { // cambio: era porcentajeConfirmacion
		if(cantidadInvitaciones == 0) return 0
		invitaciones.filter[aceptada].size as double / cantidadInvitaciones
	}

	def cantidadAmigosConcurrentes(Usuario usuario) {
		invitadosConfirmados.filter[usuario.esAmigo(invitado)].size + if(usuario.esAmigo(organizador)) 1 else 0
	}

	def invitadosConfirmados() {
		invitaciones.filter[aceptada]
	}

	def invitacionesRechazadas() {
		invitaciones.filter[rechazada]
	}

	def invitadosDisponibles() {
		capacidadMaxima - invitadosActivos
	}

	def invitadosActivos() {
		invitacionesActivas.fold(0, [suma, invitacion|suma + invitacion.cantPosiblesAsistentes])
	}

	def invitacionesActivas() {
		invitaciones.filter[!rechazada]
	}

	override getCantidadInvitaciones() {
		invitaciones.size
	}

	override esUnFracaso() {
		porcentajeAsistencia < 0.5 // cambio: era porcentajeConfirmacion
	}

	def permiteInvitacion(Invitacion invitacion) {
		invitadosDisponibles >= invitacion.cantPosiblesAsistentes
	}

	def nuevaInvitacion(Usuario invitado, int acompaniantes) {
		var invitacion = new Invitacion(this, invitado, acompaniantes)
		if (permiteInvitacion(invitacion) && organizador.invitacionValida(invitacion)) {
			invitaciones.add(invitacion)
			invitado.recibirNotificacion('Tienes una nueva invitacion al evento ' + nombre)
			invitado.agregarInvitacion(invitacion)
		} else {
			throw new EventoException("No se puede invitar")
		}
	}

	override notificarCancelacion() {
		invitacionesActivas.forEach[invitado.recibirNotificacion(mensajeCancelacion)]
	}

	override notificarPostergacion() {
		invitaciones.forEach[invitado.recibirNotificacion(mensajePostergacion)]
	}

	override devolverTotalEntradas() {}

	def ejecturarOrdenesDeInvitacion() {
		ordenesDeInvitacion.forEach[ejecutarOrden]
		ordenesDeInvitacion.clear
	}

	def agregarOrdenDeInvitacion(OrdenDeInvitacion orden) {
		ordenesDeInvitacion.add(orden)
	}

	def removerOrdenesDeInvitacion(Invitacion invitacion) {
		ordenesDeInvitacion.removeAll(ordenesDeInvitacion(invitacion))
	}

	def ordenesDeInvitacion(Invitacion _invitacion) {
		ordenesDeInvitacion.filter[invitacion == _invitacion]
	}

	override boolean puedeNotificarUsuariosCercanos() {
		false
	}

	override artistasParticipantes() {
		newArrayList
	}

	def getCantidadInvitacionesConfirmadas() {
		invitadosConfirmados.size
	}

	def getCantidadInvitacionesRechazadas() {
		invitacionesRechazadas.size
	}

	@JsonIgnore
	override getCantidadEntradasVendidas() {
		0
	}
	
	override esAbierto() {
		false
	}
	
}
