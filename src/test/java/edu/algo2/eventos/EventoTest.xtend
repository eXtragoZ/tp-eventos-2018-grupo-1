package edu.algo2.eventos

import edu.algo2.eventos.excepciones.EventoException
import edu.algo2.eventos.excepciones.ServicioTarjetaException
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import org.junit.Before
import org.junit.Test
import org.uqbar.ccService.CCResponse
import org.uqbar.ccService.CreditCard
import org.uqbar.ccService.CreditCardService
import org.uqbar.geodds.Point

import static org.junit.Assert.*
import static org.mockito.ArgumentMatchers.*
import static org.mockito.Mockito.*

class EventoTest {

	Usuario organizadorAmateur
	Usuario organizadorFree
	EventoAbierto eventoAbierto
	EventoCerrado eventoCerrado
	Locacion locacion
	Invitacion invitacionAceptada
	Invitacion invitacionRechazada
	Invitacion invitacionPendiente
	Entrada entrada
	Usuario usuario
	Usuario usuarioPro
	Servicio servicioCatering
	Servicio servicioCateringPorHora
	Servicio servicioCateringPorPersona
	Servicio servicioMultiple
	Servicio servicioConServicioMultiple

	var invitacionMock = mock(Invitacion)
	var eventoCerradoMock = mock(EventoCerrado)

	var servicioTarjeta = mock(CreditCardService)
	var tarjeta = mock(CreditCard)

	@Before
	def void init() {
		organizadorAmateur = new Usuario("Usuario Organizador", new TipoUsuarioAmateur) => [
			fechaNacimiento = LocalDate.now.minus(25, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			antisocial = false
			radioCercania = 10.5
		]

		organizadorFree = new Usuario("Usuario Organizador", new TipoUsuarioFree) => [
			fechaNacimiento = LocalDate.now.minus(25, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			antisocial = false
			radioCercania = 10.5
		]

		usuario = new Usuario("Usuario", new TipoUsuarioFree) => [
			fechaNacimiento = LocalDate.now.minus(25, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			antisocial = false
			radioCercania = 10.5
			saldo = 150000
		]

		usuarioPro = new Usuario("Usuario", new TipoUsuarioProfesional) => [
			fechaNacimiento = LocalDate.now.minus(25, ChronoUnit.YEARS)
			direccion = new Point(-35, -60)
			antisocial = false
		]

		locacion = new Locacion("Casa de Fiesta", -35, -59, 20.0)

		eventoAbierto = new EventoAbierto("La Fiesta", locacion) => [
			fechaConfirmacion = LocalDateTime.now.plus(10, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(16, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(18, ChronoUnit.DAYS).minus(1, ChronoUnit.HOURS)
			precio = 350.50
			edadMinima = 12
			organizador = organizadorAmateur
		]

		eventoCerrado = new EventoCerrado("La Fiesta Privada", locacion) => [
			fechaConfirmacion = LocalDateTime.now.plus(10, ChronoUnit.DAYS)
			fechaDesde = LocalDateTime.now.plus(16, ChronoUnit.DAYS)
			fechaHasta = LocalDateTime.now.plus(18, ChronoUnit.DAYS).minus(1, ChronoUnit.HOURS)
			capacidadMaxima = 10
			organizador = organizadorFree
		]

		invitacionAceptada = new Invitacion(eventoCerrado, usuario, 5) => [aceptada = true]

		invitacionRechazada = new Invitacion(eventoCerrado, usuario, 5) => [rechazada = true]

		invitacionPendiente = new Invitacion(eventoCerrado, usuarioPro, 5)

		entrada = new Entrada(eventoAbierto, usuario, 1)

		organizadorFree.eventos.add(eventoCerrado)

		organizadorAmateur.eventos.add(eventoAbierto)

		servicioCatering = new Servicio("Catering", new Point(-35, -58.9), 200.0) => [
			tarifaPorKm = 10.0
			tipoTarifa = new TarifaFija
		]

		servicioCateringPorHora = new Servicio("Catering", new Point(-35, -59), 10.0) => [
			tarifaPorKm = 10.0
			tipoTarifa = new TarifaPorHora
		]

		servicioCateringPorPersona = new Servicio("Catering", new Point(-35, -59), 200.0) => [
			tarifaPorKm = 10.0
			tipoTarifa = new TarifaPorPersona => [
				porcentajeMinimo = 0.1
			]
		]

		usuario.servicioTarjeta = servicioTarjeta

		servicioMultiple = new ServicioMultiple("Catering", new Point(-35, -59), 200.0, 0.15) => [
			agregarServicio(servicioCatering)
			agregarServicio(servicioCateringPorHora)
		]
	}

	@Test
	def void usuarioOrganizaEventoCerrado() {
		organizadorFree.eventos.remove(eventoCerrado)

		organizadorFree.organizarEventoCerrado(eventoCerrado)

		assertEquals(1, organizadorFree.eventos.size)
	}

	@Test
	def void usuarioOrganizaEventoAbierto() {
		organizadorAmateur.eventos.remove(eventoAbierto)

		organizadorAmateur.organizarEventoAbierto(eventoAbierto)

		assertEquals(1, organizadorAmateur.eventos.size)
	}

	@Test
	def void laCapacidadMaximaDeUnEventoAbiertoEsSuSuperficieEnKmDivididoPorElEspacioDeUnaPersona() {
		assertEquals(25, eventoAbierto.capacidadMaxima)
	}

	@Test
	def void lasEntradasDisponiblesDeUnEventoAbiertoEsLaCapacidadMaximaMenosLasEntradasVendidas() {
		eventoAbierto.entradasVendidas.add(entrada)
		assertEquals(24, eventoAbierto.entradasDisponibles)
	}

	@Test
	def void losInvitadosDisponiblesDeUnEventoCerradoEsLaCapacidadMaximaMenosLosInvitadosYAcompaniantesQueNoRechazaron() {
		eventoCerrado.invitaciones.add(invitacionAceptada)
		eventoCerrado.invitaciones.add(invitacionRechazada)
		assertEquals(4, eventoCerrado.invitadosDisponibles)
	}

	@Test
	def void laDuracionEsLaDiferenciaDeLasFechasDeInicioYFinEnHoras() {
		assertEquals(47, eventoAbierto.duracion)
	}

	@Test
	def void laDistaciaEsEntreLaLocacionDelEventoYElPuntoDadoEnKilometros() {
		assertEquals(92, eventoAbierto.distancia(new Point(-35, -60)), 1)
	}

	@Test
	def void cantidadAmigosConcurrentesOrganizadorNoAmigo() {
		eventoCerrado.invitaciones.add(new Invitacion(eventoCerrado, organizadorFree, 0) => [aceptada = true])
		eventoCerrado.invitaciones.add(new Invitacion(eventoCerrado, organizadorAmateur, 0) => [aceptada = true])
		usuario.agregarAmigo(organizadorAmateur)
		assertEquals(1, eventoCerrado.cantidadAmigosConcurrentes(usuario))
	}

	@Test
	def void cantidadAmigosConcurrentesOrganizadorEsAmigo() {
		usuario.agregarAmigo(organizadorFree)
		assertEquals(1, eventoCerrado.cantidadAmigosConcurrentes(usuario))
	}

	@Test
	def void mismoMesQueOtroEvento() {
		assertTrue(eventoCerrado.mismoMes(eventoAbierto))
	}

	@Test
	def void elEventoCerradoEsExitoso() {
		eventoCerrado.invitaciones.add(invitacionAceptada)
		assertTrue(eventoCerrado.esExitoso)
	}

	@Test
	def void elEventoAbiertoEsExitoso() {
		for (i : 0 ..< 24) {
			eventoAbierto.entradasVendidas.add(entrada)
		}
		assertTrue(eventoAbierto.esExitoso)
	}

	@Test
	def void elEventoCerradoEsUnFracaso() {
		eventoCerrado.invitaciones.add(invitacionAceptada)
		eventoCerrado.invitaciones.add(invitacionRechazada)
		eventoCerrado.invitaciones.add(invitacionRechazada)
		assertTrue(eventoCerrado.esUnFracaso)
	}

	@Test
	def void elEventoAbiertoEsUnFracaso() {
		for (i : 0 ..< 10) {
			eventoAbierto.entradasVendidas.add(entrada)
		}
		assertTrue(eventoAbierto.esUnFracaso)
	}

	@Test
	def void elUsuarioCompraEntradaEventoAbierto() {
		usuario.comprarEntrada(eventoAbierto)
		assertTrue(usuario.entradas.contains(eventoAbierto.entradasVendidas.last))
	}

	@Test(expected=EventoException)
	def void alCompraEntradaDeEventoAbiertoYNoCumpleLasCondicionesTiraExepcion() {
		usuario.fechaNacimiento = LocalDate.now
		usuario.comprarEntrada(eventoAbierto)
	}

	@Test
	def void elUsuarioTiene25Años() {
		assertEquals(25, usuario.edad)
	}

	@Test
	def void alDevolverEntradaIncrementaElSaldo() {
		usuario.comprarEntrada(eventoAbierto)
		eventoAbierto.entradasVendidas.last.devolver
		assertEquals(149930, usuario.saldo, 1)
	}

	@Test(expected=EventoException)
	def void alDevolverEntradaYFaltaMenosDeUnDiaParaElEventoTiraExepcion() {
		usuario.comprarEntrada(eventoAbierto)
		eventoAbierto.fechaDesde = LocalDateTime.now.minus(1, ChronoUnit.DAYS)
		eventoAbierto.entradasVendidas.last.devolver
	}

	@Test
	def void elOrganizadorInvitaAlUsuario() {
		organizadorFree.enviarInvitacion(eventoCerrado, usuario, 5)
		assertEquals(usuario.invitaciones, eventoCerrado.invitaciones)
	}

	@Test(expected=EventoException)
	def void alHacerUnaInvitacionDeEventoCerradoYNoCumpleLasCondicionesTiraExepcion() {
		eventoCerrado.capacidadMaxima = 0
		organizadorFree.enviarInvitacion(eventoCerrado, usuario, 5)
	}

	@Test(expected=EventoException)
	def void alAceptarUnaInvitacionYNoCumpleLasCondicionesTiraExepcion() {
		invitacionRechazada.aceptarInvitacion(2)
	}

	@Test(expected=EventoException)
	def void usuarioFreeOrganizaEventoAbiertoTiraExcepcion() {
		organizadorFree.organizarEventoAbierto(eventoAbierto)
	}

	@Test(expected=EventoException)
	def void usuarioOrganizaEventoCerradoTiraExcepcion() {
		organizadorFree.organizarEventoCerrado(eventoCerrado)
	}

	@Test
	def void elOrganizadorCancelaElEventoAbierto() {
		eventoAbierto.entradasVendidas.add(entrada)
		organizadorAmateur.cancelarEvento(eventoAbierto)
		assertTrue(eventoAbierto.cancelado)
	}

	@Test(expected=EventoException)
	def void elOrganizadorCancelaElEventoAbiertoPeroElTipoDeUsuarioNoLoPermiteTiraExcepcion() {
		organizadorFree.eventos.add(eventoCerradoMock)
		organizadorFree.cancelarEvento(eventoCerradoMock)
	}

	@Test
	def void elOrganizadorPosponeElEventoAbierto() {
		eventoAbierto.entradasVendidas.add(entrada)
		organizadorAmateur.postergarEvento(eventoAbierto, LocalDateTime.now.plus(26, ChronoUnit.DAYS))
		assertTrue(eventoAbierto.postergado)
		assertEquals(0,
			LocalDateTime.now.plus(20, ChronoUnit.DAYS).until(eventoAbierto.getFechaConfirmacion,
				ChronoUnit.MINUTES))
	}

	@Test(expected=EventoException)
	def void elOrganizadorPosponeElEventoAbiertoPeroElTipoDeUsuarioNoLoPermiteTiraExcepcion() {
		organizadorFree.eventos.add(eventoCerradoMock)

		organizadorFree.postergarEvento(eventoCerradoMock, LocalDateTime.now.plus(26, ChronoUnit.DAYS))
	}

	@Test
	def void elUsuarioRechazaUnaInvitacion() {
		organizadorFree.enviarInvitacion(eventoCerrado, usuario, 5)
		usuario.rechazarInvitacion(usuario.invitaciones.last)
		assertTrue(usuario.invitaciones.last.rechazada)
	}

	@Test
	def void elUsuarioAceptaUnaInvitacion() {
		organizadorFree.enviarInvitacion(eventoCerrado, usuario, 5)
		usuario.aceptarInvitacion(usuario.invitaciones.last, 5)
		assertTrue(usuario.invitaciones.last.aceptada)
	}

	@Test
	def void usuarioAceptaMasivamenteSeAceptaPorSerAmigoDelOrganizador() {
		usuario.agregarAmigo(organizadorFree)
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(invitacionMock.acompaniantes).thenReturn(3)
		when(eventoCerradoMock.organizador).thenReturn(organizadorFree)

		usuario.aceptacionMasiva

		verify(invitacionMock, times(1)).aceptarInvitacion(3)
	}

	@Test
	def void usuarioAceptaMasivamenteSeAceptaPorTenerMasDe4AmigosConcurrentes() {
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(invitacionMock.acompaniantes).thenReturn(3)
		when(eventoCerradoMock.organizador).thenReturn(organizadorFree)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(5)

		usuario.aceptacionMasiva

		verify(invitacionMock, times(1)).aceptarInvitacion(3)
	}

	@Test
	def void usuarioAceptaMasivamenteSeAceptaPorEstarAMenorDistaniciaQueRadioDeCercania() {
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(invitacionMock.acompaniantes).thenReturn(3)
		when(eventoCerradoMock.organizador).thenReturn(organizadorFree)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(4)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(10d)

		usuario.aceptacionMasiva

		verify(invitacionMock, times(1)).aceptarInvitacion(3)
	}

	@Test
	def void elUsuarioAceptaMasivamentePeroLaInvitacionNoCumpleNingunaCondicion() {
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(invitacionMock.acompaniantes).thenReturn(3)
		when(eventoCerradoMock.organizador).thenReturn(organizadorFree)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(4)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(11d)

		usuario.aceptacionMasiva

		verify(invitacionMock, never).aceptarInvitacion(anyInt)
	}

	@Test
	def void elUsuarioRechazaMasivamenteNoSeRechazaPorEstarMasCercaQueRadioDeCercania() {
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(7)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(10d)

		usuario.rechazoMasivo

		verify(invitacionMock, never).rechazarInvitacion
	}

	@Test
	def void elUsuarioRechazaMasivamenteNoSeRechazaPorTenerAmigosConcurrentes() {
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(1)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(30d)

		usuario.rechazoMasivo

		verify(invitacionMock, never).rechazarInvitacion
	}

	@Test
	def void usuarioRechazaMasivamenteSeRechazaPorCumplirLasCondiciones() {
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(0)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(30d)

		usuario.rechazoMasivo

		verify(invitacionMock, times(1)).rechazarInvitacion
	}

	@Test
	def void usuarioAntiSocialRechazaMasivamenteSeRechazaPorEstarLejosDeRadioDeCercania() {
		usuario => [antisocial = true]
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(7)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(30d)

		usuario.rechazoMasivo

		verify(invitacionMock, times(1)).rechazarInvitacion
	}

	@Test
	def void usuarioAntiSocialRechazaMasivamenteSeRechazaPorAmigosConcurrentesMenorADos() {
		usuario => [antisocial = true]
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(1)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(10d)

		usuario.rechazoMasivo

		verify(invitacionMock, times(1)).rechazarInvitacion
	}

	@Test
	def void elUsuarioAntisocialRechazaMasivamentePeroLaInvitacionNoCumpleNingunaCondicion() {
		usuario => [antisocial = true]
		usuario.invitaciones.add(invitacionMock)

		when(invitacionMock.evento).thenReturn(eventoCerradoMock)
		when(eventoCerradoMock.cantidadAmigosConcurrentes(usuario)).thenReturn(7)
		when(eventoCerradoMock.distancia(any(Point))).thenReturn(10d)

		usuario.rechazoMasivo

		verify(invitacionMock, never).rechazarInvitacion
	}

	@Test
	def void elCostoDelEventoEsElCostoDelServicioConTarifaFijaMasTraslado() {
		eventoAbierto => [
			servicios.add(servicioCatering)
		]
		assertEquals(300, eventoAbierto.costo, 10)
	}

	@Test
	def void elCostoDelEventoEsElCostoDelServicioConTarifaPorHoraSinTraslado() {
		eventoAbierto => [
			servicios.add(servicioCateringPorHora)
		]
		assertEquals(470, eventoAbierto.costo, 0)
	}

	@Test
	def void elCostoDelEventoEsElCostoDelServicioConTarifaPorPersonaSinTraslado() {
		eventoAbierto => [
			servicios.add(servicioCateringPorPersona)
		]
		assertEquals(500, eventoAbierto.costo, 0)
	}

	@Test
	def void alComprarEntradaSeRealizaPagoConTarjeta() {
		when(servicioTarjeta.pay(tarjeta, eventoAbierto.precio)).thenReturn(new CCResponse() => [statusCode = 0])
		usuario.comprarEntradaConTarjeta(eventoAbierto, tarjeta)
		verify(servicioTarjeta, times(1)).pay(tarjeta, eventoAbierto.precio)
	}

	@Test
	def void alComprarEntradaConTarjetaSeEfectuaTransaccionExitosa() {
		when(servicioTarjeta.pay(tarjeta, eventoAbierto.precio)).thenReturn(new CCResponse() => [statusCode = 0])
		usuario.comprarEntradaConTarjeta(eventoAbierto, tarjeta)
		assertEquals(0, servicioTarjeta.pay(tarjeta, eventoAbierto.precio).statusCode, 0)
	}

	@Test(expected=ServicioTarjetaException)
	def void alComprarEntradaConTarjetaTiraExcepcionPorDatosInvalidos() {
		when(servicioTarjeta.pay(tarjeta, eventoAbierto.precio)).thenReturn(new CCResponse() => [statusCode = 1])
		usuario.comprarEntradaConTarjeta(eventoAbierto, tarjeta)
	}

	@Test(expected=ServicioTarjetaException)
	def void alComprarEntradaConTarjetaTiraExcepcionPorPagoRechazado() {
		when(servicioTarjeta.pay(tarjeta, eventoAbierto.precio)).thenReturn(new CCResponse() => [statusCode = 2])
		usuario.comprarEntradaConTarjeta(eventoAbierto, tarjeta)
	}

	@Test(expected=EventoException)
	def void alComprarEntradaConTarjetaTiraExcepcionPorErrorEnServicioExterno() {
		when(servicioTarjeta.pay(tarjeta, eventoAbierto.precio)).thenReturn(new CCResponse() => [statusCode = 3])
		usuario.comprarEntradaConTarjeta(eventoAbierto, tarjeta)
	}

	@Test
	def void elCostoDelEventoEsElCostoDelServicioMultiple() {
		eventoAbierto => [
			servicios.add(servicioMultiple)
		]
		assertEquals((200 + 470) * (1 - 0.15) + 100, eventoAbierto.costo, 10)
//		(costo servicio 1 + costo servicio 2) * descuento + costo traslado servicio 1
	}

	@Test
	def void elCostoDelEventoEsElCostoDelServicioMultipleQueTieneOtroServicioMultiple() {
		servicioConServicioMultiple = new ServicioMultiple("Catering", new Point(-35, -59), 200.0, 0.10) => [
			agregarServicio(servicioMultiple)
			agregarServicio(servicioCateringPorHora)
			agregarServicio(servicioCateringPorPersona)
		]
		eventoAbierto => [
			servicios.add(servicioConServicioMultiple)
		]
		assertEquals((569.5 + 470 + 500) * (1 - 0.10) + 100, eventoAbierto.costo, 10)
//		(costo servicio multiple + costo servicio 1 + costo servicio 2) * descuento + traslado servicio multiple
	}
	
	@Test
	def void elCostoDelEventoEsElCostoDelServicioMultipleQueTieneOtroServicioMultipleMasTrasladoMasCaro() {
		servicioCateringPorPersona.ubicacion = new Point(-35, -59.3) 
		servicioConServicioMultiple = new ServicioMultiple("Catering", new Point(-35, -59), 200.0, 0.10) => [
			agregarServicio(servicioMultiple)
			agregarServicio(servicioCateringPorHora)
			agregarServicio(servicioCateringPorPersona)
		]
		eventoAbierto => [
			servicios.add(servicioConServicioMultiple)
		]
		assertEquals((569.5 + 470 + 500) * (1 - 0.10) + 273, eventoAbierto.costo, 1)
//		(costo servicio multiple + costo servicio 1 + costo servicio 2) * descuento + traslado servicio 2
	}

	@Test
	def void crearOrdenAceptarInvitacion() {
		invitacionPendiente.ordenarAceptarInvitacion(3)
		assertEquals(1, eventoCerrado.ordenesDeInvitacion.size, 0)
	}

	@Test(expected=EventoException)
	def void crearOrdenAceptarInvitacionTiraExcepcionPorTipoDeUsuarioFree() {
		invitacionPendiente.invitado = usuario
		invitacionPendiente.ordenarAceptarInvitacion(3)
	}

	@Test
	def void crearOrdenRechazarInvitacion() {
		invitacionPendiente.ordenarRechazarInvitacion
		assertEquals(1, eventoCerrado.ordenesDeInvitacion.size, 0)
	}

	@Test
	def void ejecutoOrdenAceptarInvitacion() {
		invitacionPendiente.ordenarAceptarInvitacion(3)
		eventoCerrado.ejecturarOrdenesDeInvitacion
		assertTrue(invitacionPendiente.aceptada)
	}

	@Test
	def void ejecutoOrdenRechazarInvitacion() {
		invitacionPendiente.ordenarRechazarInvitacion
		eventoCerrado.ejecturarOrdenesDeInvitacion
		assertTrue(invitacionPendiente.rechazada)
	}

	@Test
	def void ejecutoOrdenAceptarInvitacionNoAceptaInvitacionPorTenerMasAcompaniantes() {
		invitacionPendiente.ordenarAceptarInvitacion(6)
		eventoCerrado.ejecturarOrdenesDeInvitacion
		assertFalse(invitacionPendiente.aceptada)
	}

	@Test
	def void ejecutoOrdenRechazarInvitacionNoRechazaInvitacionPorNoEstarPendiente() {
		invitacionPendiente.ordenarRechazarInvitacion
		invitacionPendiente.aceptarInvitacion(3)
		eventoCerrado.ejecturarOrdenesDeInvitacion
		assertFalse(invitacionPendiente.rechazada)
	}

	@Test
	def void ejecutarOrdenesEliminaLasOrdenesGuardadas() {
		invitacionPendiente.ordenarAceptarInvitacion(3)
		eventoCerrado.ejecturarOrdenesDeInvitacion
		assertTrue(eventoCerrado.ordenesDeInvitacion.isEmpty)
	}
	
	@Test
	def void elUsuarioOrganizadorAmateurTieneActividad2() {
		organizadorAmateur.agregarInvitacion(invitacionAceptada)
		assertEquals(2,organizadorAmateur.getActividad)
	}

}
