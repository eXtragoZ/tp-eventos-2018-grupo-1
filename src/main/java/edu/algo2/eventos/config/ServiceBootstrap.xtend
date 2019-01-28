package edu.algo2.eventos.config

import edu.algo2.eventos.EventoAbierto
import edu.algo2.eventos.EventoCerrado
import edu.algo2.eventos.Locacion
import edu.algo2.eventos.Servicio
import edu.algo2.eventos.TarifaFija
import edu.algo2.eventos.TarifaPorHora
import edu.algo2.eventos.TarifaPorPersona
import edu.algo2.eventos.Usuario
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.geodds.Point
import org.uqbar.updateService.UpdateService
import edu.algo2.eventos.Artista

class ServiceBootstrap {
	def static run() {
		val repoUsuarios = ServiceLocator.instance.repoUsuarios
		val repoLocaciones = ServiceLocator.instance.repoLocaciones
		val repoServicios = ServiceLocator.instance.repoServicios
		val repoEventos = ServiceLocator.instance.repoEventos
		
		val mollo = new Artista("Ricardo Mollo")

		val locacion1 = new Locacion("Casa de Fiesta", -35, -59, 20.0)
		val locacion2 = new Locacion("Salón El Abierto", -34.603759, -58.381586, 200.0)
		val locacion3 = new Locacion("Estadio Obras", -34.572224, -58.535651, 2000.0)
		val locacion4 = new Locacion("Saloncito", -34.603759, -58.381586, 200.0)
		val locacion5 = new Locacion("Castillo para eventos", -94.603759, -98.381586, 200.0)
		val locacion6 = new Locacion("Tropitango", -34.603759, -58.381586, 200.0)
		val locacion7 = new Locacion("Chacra en el campo", -134.603759, -90.381586, 200.0)
		val locacion8 = new Locacion("Estadio Único de La Plata", -150.603759, -120.381586, 200.0)

		val lucas_capo = new Usuario("lucas_capo", repoUsuarios.tipoUsuarioAmateur) => [
			fechaNacimiento = LocalDate.now.minus(25, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "Lucas Lopez"
			email = "lucas_93@hotmail.com"
			radioCercania = 100.00
		]
		val martin1990 = new Usuario("martin1990", repoUsuarios.tipoUsuarioProfesional) => [
			fechaNacimiento = LocalDate.now.minus(28, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "Martín Varela"
			email = "martinvarela90@yahoo.com"
			radioCercania = 100.00
		]
		val elBarto = new Usuario("elBarto", repoUsuarios.tipoUsuarioFree) => [
			fechaNacimiento = LocalDate.now.minus(10, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "Bart Simpson"
			email = "elbarto@gmail.com"
			radioCercania = 100.00
		]
		val elHomo = new Usuario("elHomo", repoUsuarios.tipoUsuarioFree) => [
			fechaNacimiento = LocalDate.now.minus(45, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "Homero Simpson"
			email = "homerosimpson@gmail.com"
			radioCercania = 100.00
		]
		val usuarioOrganizador = new Usuario("elOrganizer", repoUsuarios.tipoUsuarioProfesional) => [
			fechaNacimiento = LocalDate.now.minus(28, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "Ricardo Montaner"
			email = "ricardito@yahoo.com"
			radioCercania = 200.00
			saldo = 15000
			agregarAmigo(martin1990)
			agregarArtista(mollo)
		]
		val usuarioSolitario = new Usuario("elEmo", repoUsuarios.tipoUsuarioProfesional) => [
			fechaNacimiento = LocalDate.now.minus(28, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			nombreApellido = "Emilio Solano"
			email = "solito@yahoo.com"
		]
		repoUsuarios => [
			create(usuarioOrganizador)
			create(lucas_capo)
			create(martin1990)
			create(elBarto)
			create(elHomo)
			create(usuarioSolitario)
		]

		repoLocaciones => [
			create(locacion1)
			create(locacion2)
			create(locacion3)
			create(locacion4)
			create(locacion5)
			create(locacion6)
			create(locacion7)
			create(locacion8)
		]

		repoServicios => [
			create(new Servicio("Fotografos unidos", new Point(-34, -51), 1000.0) => [
				tipoTarifa = new TarifaFija
				tarifaPorKm = 11.0
			])
			create(new Servicio("Show en vivo", new Point(-34, -51), 1000.0) => [
				tipoTarifa = new TarifaPorHora
				tarifaPorKm = 0.0
			])
			create(new Servicio("Catering Food Party", new Point(-34, -51), 1000.0) => [
				tipoTarifa = new TarifaPorPersona => [porcentajeMinimo = 0.1]
				tarifaPorKm = 30.0
			])
		]

		val evento1 = new EventoAbierto("La Fiesta", locacion1) => [
			fechaConfirmacion = LocalDateTime.now.plus(10, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(16, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(18, ChronoUnit.DAYS).minus(1, ChronoUnit.HOURS)
			precio = 350.50
			edadMinima = 12
			
			lucas_capo.organizarEventoAbierto(it)
			nuevaEntrada(elHomo)
			nuevaEntrada(martin1990)
			nuevaEntrada(usuarioOrganizador)
		]


		val evento2 = new EventoCerrado("La Fiesta Privada", locacion1) => [
			fechaConfirmacion = LocalDateTime.now.plus(10, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(16, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(18, ChronoUnit.DAYS).minus(1, ChronoUnit.HOURS)
			capacidadMaxima = 100
			
			martin1990.organizarEventoCerrado(it)
			nuevaInvitacion(lucas_capo, 5)
			nuevaInvitacion(martin1990, 4)
			nuevaInvitacion(usuarioOrganizador, 2)
		]

		val evento3 = new EventoCerrado("La Fiestita", locacion6) => [
			fechaConfirmacion = LocalDateTime.now.plus(1, ChronoUnit.HOURS)
			fechaDesde = LocalDateTime.now.plus(3, ChronoUnit.HOURS)
			fechaHasta = LocalDateTime.now.plus(1, ChronoUnit.DAYS)
			capacidadMaxima = 100
			
			usuarioOrganizador.organizarEventoCerrado(it)
			nuevaInvitacion(lucas_capo, 2)
			nuevaInvitacion(martin1990, 5)
			nuevaInvitacion(elBarto, 4)
			nuevaInvitacion(elHomo, 3)
		]
		
		val evento4 = new EventoCerrado("Evento de hoy", locacion2) => [
			fechaConfirmacion = LocalDateTime.now.plus(1, ChronoUnit.HOURS)
			fechaDesde = LocalDateTime.now.plus(1, ChronoUnit.HOURS)
			fechaHasta = LocalDateTime.now.plus(6, ChronoUnit.HOURS)
			capacidadMaxima = 25
			
			lucas_capo.organizarEventoCerrado(it)
			nuevaInvitacion(usuarioOrganizador, 4)
			nuevaInvitacion(martin1990, 3)
			nuevaInvitacion(elBarto, 2)
			nuevaInvitacion(elHomo, 1)
			nuevaInvitacion(usuarioSolitario, 0)
		]
		
		val evento5 = new EventoCerrado("Evento semanal 33", locacion4) => [
			fechaConfirmacion = LocalDateTime.now.plus(4, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(5, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(5, ChronoUnit.DAYS).plus(5, ChronoUnit.HOURS)
			capacidadMaxima = 70
			
			elBarto.organizarEventoCerrado(it)
			nuevaInvitacion(usuarioOrganizador, 0)
			nuevaInvitacion(elHomo, 1)
			nuevaInvitacion(martin1990, 1)
		]
		
		val evento6 = new EventoAbierto("Mi Cumpleaños", locacion5) => [
			fechaConfirmacion = LocalDateTime.now.plus(8, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(8, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(8, ChronoUnit.DAYS).plus(5, ChronoUnit.HOURS)
			precio = 0.0
			edadMinima = 0
			
			usuarioOrganizador.organizarEventoAbierto(it)

			nuevaEntrada(elHomo)
			nuevaEntrada(martin1990)
			nuevaEntrada(lucas_capo)
		]
		
		val evento7 = new EventoAbierto("Sumo en Obras", locacion3) => [
			fechaConfirmacion = LocalDateTime.now.plus(85, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(85, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(85, ChronoUnit.DAYS).plus(5, ChronoUnit.HOURS)
			precio = 700.0
			edadMinima = 18
			
			martin1990.organizarEventoAbierto(it)
			nuevaEntrada(usuarioOrganizador,2)
		]
		
		val evento8 = new EventoAbierto("El Pepo Libre", locacion6) => [
			fechaConfirmacion = LocalDateTime.now.plus(5, ChronoUnit.HOURS)
			fechaDesde = LocalDateTime.now.plus(5, ChronoUnit.HOURS)
			fechaHasta = LocalDateTime.now.plus(12, ChronoUnit.HOURS)
			precio = 350.0
			edadMinima = 18
			
			martin1990.organizarEventoAbierto(it)
			nuevaEntrada(usuarioOrganizador,2)
		]
		
		val evento9 = new EventoAbierto("Fiesta en el campo", locacion7) => [
			fechaConfirmacion = LocalDateTime.now.plus(15, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(15, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(15, ChronoUnit.DAYS).plus(5, ChronoUnit.HOURS)
			precio = 300.0
			edadMinima = 18
			
			usuarioSolitario.organizarEventoAbierto(it)
			nuevaEntrada(martin1990)
		]
		
		val evento10 = new EventoAbierto("Divididos en La Plata", locacion8) => [
			fechaConfirmacion = LocalDateTime.now.plus(123, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(123, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(123, ChronoUnit.DAYS).plus(5, ChronoUnit.HOURS)
			precio = 790.0
			edadMinima = 5
			
			it.artistasParticipantes().add(mollo)
			usuarioSolitario.organizarEventoAbierto(it)
			nuevaEntrada(martin1990,249)
		]

		lucas_capo.invitaciones.forEach[aceptarInvitacion(acompaniantes)]
		elBarto.invitaciones.forEach[aceptarInvitacion(acompaniantes)]
		elHomo.invitaciones.forEach[aceptarInvitacion(acompaniantes)]
		usuarioSolitario.invitaciones.forEach[rechazarInvitacion]
		
		repoUsuarios.elementos.filter[it != usuarioOrganizador].forEach[
			usuarioOrganizador.agregarAmigo(it)
		]
		
		val actualizacion = new Actualizacion
		repoLocaciones.servicioActualizacion = actualizacion
		repoUsuarios.servicioActualizacion = actualizacion
		repoServicios.servicioActualizacion = actualizacion
		
		repoEventos => [
			create(evento1)
			create(evento2)
			create(evento3)
			create(evento4)
			create(evento5)
			create(evento6)
			create(evento7)
			create(evento8)
			create(evento9)
			create(evento10)
		]
	}
}

@Accessors
class Actualizacion extends UpdateService {

	override getUserUpdates() {
		'[{"nombreUsuario":"nose","nombreApellido":"El Que no sabe","email":"no_se@hotmail.com","fechaNacimiento":"15/01/1992","direccion":{"calle":"25 de Mayo","numero":3918,"localidad":"San Martín","provincia":"Buenos Aires","coordenadas":{"x":-34.572224,"y":51.535651}}},{"nombreUsuario":"martin1990","nombreApellido":"Martín Varela","email":"otromail@yahoo.com","fechaNacimiento":"18/11/1990","direccion":{"calle":"Av. Triunvirato","numero":4065,"localidad":"CABA","provincia":"","coordenadas":{"x":-33.58236,"y":60.516598}}}]'
	}

	override getLocationUpdates() {
		'[{"x":-34.603759,"y":-58.381586,"nombre":"El quinchito","superficie":150.00},{"x":-34.603759,"y":-60.381586,"nombre":"Salón El Abierto"},{"x":-34.572224,"y":-58.535651,"nombre":"Estadio Obras"}]'
	}

	override getServiceUpdates() {
		'[{"descripcion":"Catering Re Loco","tarifaServicio":{"tipo":"TPH","valor":1000.00,"minimo":3500.00},"tarifaTraslado":30.00,"ubicacion":{"x":-34.572224,"y":58.535651}},{"descripcion":"Catering Food Party","tarifaServicio":{"tipo":"TF","valor":5000.00},"tarifaTraslado":30.00,"ubicacion":{"x":-34.572224,"y":58.535651}}]'
	}
}
