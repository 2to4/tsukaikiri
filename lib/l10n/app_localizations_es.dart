// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tsukaikiri';

  @override
  String get inventoryTitle => 'Inventario';

  @override
  String get emptyInventory =>
      'Aún no hay ingredientes.\nToca + para añadir uno.';

  @override
  String get addIngredient => 'Añadir ingrediente';

  @override
  String get editIngredient => 'Editar ingrediente';

  @override
  String get filterAll => 'Todos';

  @override
  String get categoryMeat => 'Carne';

  @override
  String get categoryFish => 'Pescado';

  @override
  String get categoryVegetable => 'Verduras';

  @override
  String get categoryFruit => 'Fruta';

  @override
  String get categoryDairy => 'Lácteos';

  @override
  String get categoryEgg => 'Huevos';

  @override
  String get categoryGrain => 'Cereales y básicos';

  @override
  String get categorySeasoning => 'Condimentos';

  @override
  String get categoryFrozen => 'Congelados';

  @override
  String get categoryBeverage => 'Bebidas';

  @override
  String get categoryStaple => 'Despensa';

  @override
  String get categoryOther => 'Otros';

  @override
  String get unitPiece => 'uds';

  @override
  String get unitGram => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'L';

  @override
  String get unitBottle => 'botellas';

  @override
  String get unitSheet => 'hojas';

  @override
  String get unitPack => 'paquetes';

  @override
  String get unitBag => 'bolsas';

  @override
  String get unitGo => 'go';

  @override
  String get unitCup => 'tazas';

  @override
  String get unitCan => 'latas';

  @override
  String get unitCustom => 'Personalizada…';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get fieldQuantity => 'Cantidad';

  @override
  String get fieldUnit => 'Unidad';

  @override
  String get fieldExpiry => 'Fecha de caducidad';

  @override
  String get fieldExpiryOptional => 'Fecha de caducidad (opcional)';

  @override
  String get customUnitLabel => 'Unidad personalizada';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionClear => 'Borrar';

  @override
  String get validationNameRequired => 'Introduce un nombre';

  @override
  String get validationQuantityInvalid => 'Introduce un número mayor que 0';

  @override
  String get validationUnitRequired => 'Introduce una unidad';

  @override
  String get deleteConfirmTitle => '¿Eliminar este ingrediente?';

  @override
  String deleteConfirmBody(String name) {
    return '$name se eliminará de tu inventario.';
  }

  @override
  String get expiryExpired => 'Caducado';

  @override
  String get expiryToday => 'Hoy';

  @override
  String expiryInDays(int days) {
    return 'Quedan $days días';
  }

  @override
  String get expiryNone => 'Sin fecha';

  @override
  String get selectIngredientPrompt =>
      'Selecciona un ingrediente para ver los detalles';

  @override
  String inventoryCountLine(int count) {
    return '$count artículos en la nevera · los más próximos primero';
  }

  @override
  String get groupNow => 'Usar hoy o pronto';

  @override
  String get groupWeek => 'Esta semana';

  @override
  String get groupPlenty => 'Tiempo de sobra';

  @override
  String get groupNoDate => 'Sin fecha de caducidad';

  @override
  String get swipeHint =>
      '← Desliza una tarjeta a la izquierda para acciones rápidas';

  @override
  String get emptyInventoryTitle => 'Tu inventario está vacío';

  @override
  String get emptyInventoryBody =>
      'Añade ingredientes y te sugeriremos comidas para aprovecharlos, empezando por los que caducan antes.';

  @override
  String get cameraRegister => 'Añadir con la cámara';

  @override
  String get manualAdd => 'Añadir manualmente';

  @override
  String get suggestRecipes => 'Sugerir recetas';

  @override
  String get suggestRecipesSub => 'Ver menú para aprovechar';

  @override
  String get actionUsedUp => 'Agotado';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get toastUsedUp => 'Marcado como agotado';

  @override
  String get toastDeleted => 'Eliminado';

  @override
  String get detailAddToShoppingList => 'Añadir a la lista de la compra';

  @override
  String get detailAddedToShoppingList => 'Añadido a la lista de la compra';

  @override
  String get detailShoppingListNotConfigured =>
      'Elige primero una lista de la compra en Ajustes';

  @override
  String get detailViewRecipe => 'Ver recetas';

  @override
  String get comingSoon => 'Esta función llegará en una próxima actualización.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Español';

  @override
  String get languageHint =>
      'Elegir «Predeterminado del sistema» sigue el idioma de tu dispositivo.';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionAi => 'IA (reconocimiento y recetas)';

  @override
  String get settingsSectionIntegration => 'Integraciones';

  @override
  String get settingsSectionData => 'Datos';

  @override
  String get settingsSectionSupport => 'Soporte';

  @override
  String get settingsAiProvider => 'Proveedor de IA';

  @override
  String get settingsApiKey => 'Clave de API';

  @override
  String get settingsImageRecognition => 'Reconocimiento de imágenes';

  @override
  String get settingsShoppingList => 'Lista de la compra';

  @override
  String get settingsAppliances => 'Electrodomésticos';

  @override
  String get settingsCloudSync => 'Sincronización en la nube';

  @override
  String get settingsSupportAuthor => 'Apoyar al autor';

  @override
  String get settingsHelp => 'Ayuda';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsSyncOffNote =>
      'La sincronización está desactivada. Los datos se guardan solo en este dispositivo.';

  @override
  String settingsVersionLine(String version) {
    return 'Tsukaikiri · v$version';
  }

  @override
  String get shellNavInventory => 'Inventario';

  @override
  String get shellNavCamera => 'Cámara';

  @override
  String get shellNavMeals => 'Planificador de comidas';

  @override
  String get shellNavShopping => 'Lista de la compra';

  @override
  String get shellNavOnboarding => 'Asistente de configuración';

  @override
  String get shellNavSettings => 'Ajustes';

  @override
  String get shellNavHelp => 'Ayuda';

  @override
  String get shellSectionMain => 'PRINCIPAL';

  @override
  String get shellSectionOther => 'OTROS';

  @override
  String shellInventoryCount(int count) {
    return '$count artículos';
  }

  @override
  String get shellPlaceholder => 'Esta pantalla llegará pronto.';

  @override
  String get shellPlaceholderTitle => 'En construcción';

  @override
  String get desktopCategoryLabel => 'Categoría';

  @override
  String get desktopGroupNow => 'Hoy y pronto';

  @override
  String get desktopGroupWeek => 'Esta semana';

  @override
  String get desktopGroupPlenty => 'Tiempo de sobra';

  @override
  String get desktopSearchPlaceholder => 'Buscar ingredientes…';

  @override
  String get inventorySearchHint => 'Buscar artículos…';

  @override
  String inventorySearchEmpty(String query) {
    return 'Ningún artículo coincide con «$query»';
  }

  @override
  String get desktopNoResults => 'No hay ingredientes que coincidan';

  @override
  String get desktopSelectPrompt => 'Selecciona un ingrediente';

  @override
  String get desktopSelectBody =>
      'Haz clic en un elemento de la lista para ver los detalles y editar.';

  @override
  String get desktopAddIngredient => 'Añadir ingrediente';

  @override
  String get desktopAddIngredientShortcut => '⌘N';

  @override
  String get desktopCameraRegister => 'Cámara';

  @override
  String get desktopCameraShortcut => '⌘K';

  @override
  String get desktopSuggestMeals => 'Sugerir comidas';

  @override
  String get desktopSuggestMealsShortcut => '⌘R';

  @override
  String desktopQuantityUnit(String qty, String unit) {
    return '$qty $unit';
  }

  @override
  String desktopExpiryDaysOver(int n) {
    return '$n días de retraso';
  }

  @override
  String get desktopExpiryToday => 'Hoy';

  @override
  String desktopExpiryDaysLeft(int n) {
    return 'Quedan $n días';
  }

  @override
  String get desktopDetailQty => 'Cantidad';

  @override
  String get desktopDetailCategory => 'Categoría';

  @override
  String get desktopDetailExpiry => 'Caducidad';

  @override
  String get desktopSuggestWithIngredient => 'Sugerir comida con esto';

  @override
  String get desktopUsedUp => 'Marcar como agotado';

  @override
  String get desktopDelete => 'Eliminar';

  @override
  String get desktopEditHint =>
      'Usa el botón de editar para cambiar el nombre y la cantidad.';

  @override
  String desktopCountSuffix(int n) {
    return '$n artículos';
  }

  @override
  String get settingsNavAi => 'IA';

  @override
  String get settingsNavGeneral => 'General';

  @override
  String get settingsNavShopping => 'Lista de la compra';

  @override
  String get settingsNavAppliance => 'Electrodomésticos';

  @override
  String get settingsNavData => 'Datos';

  @override
  String get settingsNavSupport => 'Soporte';

  @override
  String get settingsAiHeading =>
      'IA (reconocimiento y sugerencias de comidas)';

  @override
  String get settingsAiVisionYes => 'Reconocimiento de imágenes';

  @override
  String get settingsAiVisionNo => 'Sin reconocimiento de imágenes';

  @override
  String get settingsAiOnDeviceDesc =>
      'Gratis · sin clave de API · sin conexión';

  @override
  String get settingsAiOnDeviceUnavailable =>
      'No disponible en este dispositivo';

  @override
  String get settingsAiOnDeviceNoKeyNote =>
      'La IA en el dispositivo funciona sin clave de API. Nada sale de tu dispositivo.';

  @override
  String get aiUnavailableTitle => 'La IA no está disponible';

  @override
  String get aiUnavailableBody =>
      'Este dispositivo no admite la IA en el dispositivo. Puedes añadir tu propia clave de API en Ajustes → IA para usar la IA en la nube. El inventario y la lista de la compra funcionan sin IA.';

  @override
  String get aiCloudKeyMissingTitle => 'No hay clave de API registrada';

  @override
  String get aiCloudKeyMissingBody =>
      'La IA en la nube seleccionada no tiene clave de API, o la clave no es válida. Añade una clave en Ajustes → IA, o cambia a la IA en el dispositivo en dispositivos compatibles. El inventario y la lista de la compra funcionan sin IA.';

  @override
  String get settingsApiKeyHeading => 'Clave de API';

  @override
  String get settingsApiKeyPlaceholder => 'Pega tu clave de API';

  @override
  String get settingsApiKeyNote =>
      'Tu clave se guarda de forma segura en este dispositivo.';

  @override
  String get settingsApiKeySave => 'Guardar';

  @override
  String get settingsApiKeyChange => 'Cambiar';

  @override
  String get settingsApiKeyDelete => 'Eliminar';

  @override
  String settingsApiKeyGetLink(String provider) {
    return 'Obtener clave de $provider';
  }

  @override
  String settingsApiKeySavedMasked(String masked) {
    return 'Guardada: $masked';
  }

  @override
  String get settingsModelHeading => 'Modelo';

  @override
  String get settingsModelFetch => 'Obtener modelos';

  @override
  String get settingsModelFetching => 'Obteniendo…';

  @override
  String get settingsModelNeedKey =>
      'Guarda primero una clave de API para obtener modelos.';

  @override
  String settingsModelCurrent(String model) {
    return 'En uso: $model';
  }

  @override
  String get settingsModelDefault => 'Predeterminado (automático)';

  @override
  String get settingsNetworkError =>
      'Muévete a una zona con buena señal o conéctate a Wi-Fi.';

  @override
  String get settingsGeneralHeading => 'General';

  @override
  String get settingsShoppingHeading => 'Lista de la compra';

  @override
  String get settingsShoppingLinkedApp => 'App vinculada';

  @override
  String get settingsShoppingReminders => 'Recordatorios (macOS)';

  @override
  String get settingsShoppingLists => 'Lista de destino';

  @override
  String get settingsShoppingLoad => 'Cargar listas';

  @override
  String get settingsShoppingLoading => 'Cargando…';

  @override
  String settingsShoppingCurrent(String name) {
    return 'Actual: $name';
  }

  @override
  String get settingsShoppingNone => 'Sin seleccionar';

  @override
  String get settingsShoppingNewName => 'Nombre de la nueva lista';

  @override
  String get settingsShoppingCreate => 'Crear';

  @override
  String get settingsShoppingLoadError =>
      'No se pudieron cargar las listas. Comprueba que el acceso a Recordatorios esté permitido.';

  @override
  String get settingsApplianceHeading => 'Electrodomésticos';

  @override
  String get settingsApplianceHotcook => 'Hotcook';

  @override
  String get settingsApplianceHealsio => 'Healsio';

  @override
  String get settingsApplianceNotOwned => 'No lo tengo';

  @override
  String get settingsApplianceSeries => 'Serie';

  @override
  String get settingsApplianceCapacity => 'Capacidad';

  @override
  String get settingsApplianceNote =>
      'Los electrodomésticos registrados reciben recetas prioritarias, con las raciones ajustadas al modelo y la capacidad.';

  @override
  String get settingsDataHeading => 'Sincronización de datos';

  @override
  String get settingsDataICloud => 'Sincronización con iCloud';

  @override
  String get settingsDataComingSoon => 'La sincronización llegará pronto.';

  @override
  String settingsDataLastBackup(String date) {
    return 'Última copia: $date';
  }

  @override
  String get settingsDataNeverBackedUp => 'Aún no hay copia';

  @override
  String get settingsDataBackupButton => 'Hacer copia ahora';

  @override
  String get settingsDataRestoreButton => 'Restaurar desde copia';

  @override
  String get settingsDataBackupSuccess => 'Copia guardada.';

  @override
  String get settingsDataRestoreConfirmTitle => '¿Restaurar la copia?';

  @override
  String settingsDataRestoreConfirmBody(int count) {
    return 'El inventario actual ($count artículos) y los ajustes se reemplazarán por el contenido del archivo de copia. Esto no se puede deshacer.';
  }

  @override
  String get settingsDataRestoreConfirmOk => 'Restaurar';

  @override
  String get settingsDataSyncEnabledLabel => 'Copia automática en iCloud';

  @override
  String get settingsDataSyncEnabledDesc =>
      'Hace una copia automáticamente cuando cambian el inventario o los ajustes';

  @override
  String get settingsDataSyncKeepOnFailureLabel =>
      'Seguir activado si falla la copia';

  @override
  String get settingsDataSyncKeepOnFailureDesc =>
      'Mantiene la copia automática activada aunque la primera copia falle (p. ej. sin sesión en iCloud). Desactívalo para revertir el interruptor si falla.';

  @override
  String get settingsDataCameraPreserveLabel =>
      'Conservar progreso de la cámara';

  @override
  String get settingsDataCameraPreserveDesc =>
      'Conserva las fotos y los candidatos editados al salir y volver a la pantalla de la cámara. Desactívalo para empezar de cero cada vez.';

  @override
  String settingsDataRestoreConfirmDate(String date) {
    return 'Fecha de la copia: $date';
  }

  @override
  String settingsDataRestoreConfirmCount(int count) {
    return 'Artículos en la copia: $count';
  }

  @override
  String get settingsDataRestoreConfirmWarning =>
      'Esto reemplazará tus datos actuales. No se puede deshacer.';

  @override
  String get settingsDataICloudNotAvailable =>
      'iCloud no está disponible. Inicia sesión en iCloud en Ajustes del Sistema.';

  @override
  String get settingsDataRestoreSuccess => 'Datos restaurados.';

  @override
  String get settingsDataRestoreFormatError =>
      'Archivo de copia no válido. Usa una copia creada por Tsukaikiri.';

  @override
  String get settingsDataRestoreNewerVersionError =>
      'Esta copia se creó con una versión más reciente de Tsukaikiri. Actualiza primero la app.';

  @override
  String get settingsDataNoBackupFound =>
      'No se encontró ninguna copia en iCloud.';

  @override
  String settingsDataSyncFailed(String detail) {
    return 'Algo salió mal: $detail';
  }

  @override
  String get settingsSupportHeading => 'Soporte';

  @override
  String get settingsSupportComingSoon => '(próximamente)';

  @override
  String get settingsSupportHelp => 'Ayuda';

  @override
  String get settingsSupportAbout => 'Acerca de';

  @override
  String settingsAboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsAboutClose => 'Cerrar';

  @override
  String get mealsConditionsLabel => 'Condiciones';

  @override
  String get mealsCondAuto => 'Cualquiera';

  @override
  String get mealsCondMainOnly => 'Solo plato principal';

  @override
  String get mealsCondOneMore => 'Un plato más';

  @override
  String get mealsCondQuick => 'Rápido';

  @override
  String get mealsSuggestButton => 'Sugerir según el inventario';

  @override
  String get mealsSuggestShortcut => '⌘R';

  @override
  String get mealsBeforeBody => 'Haz clic en «Sugerir según el inventario»';

  @override
  String get mealsGenerating => 'Generando recetas…';

  @override
  String get mealsLowStockBanner =>
      'Hay poco inventario, así que las sugerencias incluyen recetas que requieren compras.';

  @override
  String mealsFocusBanner(String name) {
    return 'Sugiriendo a partir de «$name»';
  }

  @override
  String get mealsErrorNetwork =>
      'No se pudieron obtener sugerencias. Muévete a un lugar con mejor señal o conéctate a Wi-Fi y reinténtalo.';

  @override
  String get mealsErrorNoApiKey =>
      'No hay ninguna clave de API de IA registrada. Añade una clave de API en Ajustes.';

  @override
  String get mealsErrorOnDevice =>
      'La IA no pudo generar una respuesta. Puede que el modelo se esté preparando o que haya demasiados artículos. Inténtalo con menos artículos o espera un momento y reinténtalo.';

  @override
  String get cameraVisionUnavailableTitle =>
      'No se puede registrar desde fotos en este dispositivo';

  @override
  String get cameraVisionUnavailableBody =>
      'La IA en el dispositivo no puede leer fotos. Añade en Ajustes → IA una clave de IA en la nube compatible con imágenes, o añade los artículos manualmente.';

  @override
  String get mealsRetry => 'Reintentar';

  @override
  String get mealsOpenSettings => 'Abrir Ajustes';

  @override
  String get mealsBadgeUseNear => 'Usar pronto';

  @override
  String get mealsApplianceHotcook => '🍲 Hotcook';

  @override
  String get mealsApplianceHealsio => '♨️ Healsio';

  @override
  String get mealsApplianceNormal => '🔥 Fogón';

  @override
  String mealsCookMinutes(int minutes) {
    return '⏱ $minutes min';
  }

  @override
  String get mealsDetailEmpty => 'Selecciona una receta';

  @override
  String mealsCookTime(int minutes) {
    return 'Tiempo de cocción $minutes min';
  }

  @override
  String get mealsToShopping => 'Añadir a la lista de la compra';

  @override
  String get mealsDecide => 'Elegir esta receta';

  @override
  String get mealsDecided => 'Elegida';

  @override
  String get mealsIngredientsHeading => 'Ingredientes';

  @override
  String get mealsStepsHeading => 'Pasos';

  @override
  String get mealsTitle => 'Ideas de comidas';

  @override
  String get mealsSubtitle =>
      'Planificaremos comidas para aprovechar lo que tienes.';

  @override
  String get mealsConditionsPrompt => '¿Qué tipo de comida?';

  @override
  String get mealsGeneratingTitle => 'Planificando tus comidas';

  @override
  String get mealsCancel => 'Cancelar';

  @override
  String mealsResultCount(int count) {
    return '$count ideas a partir de tu inventario';
  }

  @override
  String get mealsResultBanner =>
      'Hemos elegido recetas que aprovechan los ingredientes que caducan pronto.';

  @override
  String mealsToShoppingCount(int count) {
    return 'Añadir a la lista de la compra ($count)';
  }

  @override
  String mealsShortageCount(int count) {
    return 'Comprar $count';
  }

  @override
  String get mealsIngInStock => 'En stock';

  @override
  String get mealsIngToBuy => 'Comprar';

  @override
  String get mealsErrorTitle => 'No se pudieron obtener sugerencias';

  @override
  String get mealsErrorNoApiKeyTitle => 'No hay clave de API registrada';

  @override
  String get mealsBackToInventory => 'Volver al inventario';

  @override
  String shoppingMissingCount(int n) {
    return 'Artículos que faltan ($n)';
  }

  @override
  String get shoppingSelectAll => 'Seleccionar todo';

  @override
  String get shoppingDeselectAll => 'Deseleccionar todo';

  @override
  String shoppingForLabel(String meal) {
    return 'para $meal';
  }

  @override
  String get shoppingRightPanelTitle => 'Lista de destino';

  @override
  String get shoppingAppLabel => 'App';

  @override
  String get shoppingRemindersApp => 'Recordatorios (macOS)';

  @override
  String get shoppingLoadLists => 'Cargar listas';

  @override
  String get shoppingLoadingLists => 'Cargando…';

  @override
  String get shoppingNewListName => 'Nombre de la nueva lista';

  @override
  String get shoppingCreateList => 'Crear';

  @override
  String shoppingAddButton(String list, int n) {
    return 'Añadir a «$list» ($n artículos)';
  }

  @override
  String get shoppingAddButtonNoList => 'Selecciona primero una lista';

  @override
  String shoppingDoneTitle(int n) {
    return '$n artículos añadidos';
  }

  @override
  String shoppingDoneBody(String list) {
    return 'Encuéntralos en Recordatorios: «$list»';
  }

  @override
  String get shoppingOpenReminders => 'Abrir Recordatorios';

  @override
  String get shoppingBackToInventory => 'Volver al inventario';

  @override
  String get shoppingEmptyTitle => 'No faltan ingredientes';

  @override
  String get shoppingEmptyBody =>
      'Decide tus comidas para ver qué necesitas comprar.';

  @override
  String get shoppingGoToMeals => 'Ir al planificador de comidas';

  @override
  String get shoppingErrorTitle => 'No se pudo añadir a la lista';

  @override
  String get shoppingErrorNetwork =>
      'Muévete a una zona con buena señal o conéctate a Wi-Fi. Comprueba también que el acceso a Recordatorios esté permitido.';

  @override
  String get shoppingRetry => 'Reintentar';

  @override
  String get shoppingListLoadError =>
      'No se pudieron cargar las listas. Comprueba que el acceso a Recordatorios esté permitido.';

  @override
  String shoppingQtyUnit(int qty) {
    return '$qty uds';
  }

  @override
  String get shoppingMobileTitle => 'Lista de la compra';

  @override
  String get shoppingMobileSubtitle =>
      'Ingredientes que faltan para tus comidas';

  @override
  String shoppingMobileSummary(int total, int chosen) {
    return '$total faltan · añadiendo $chosen';
  }

  @override
  String get shoppingDest => 'Añadir a';

  @override
  String get shoppingChange => 'Cambiar';

  @override
  String get shoppingAdding => 'Añadiendo a Recordatorios…';

  @override
  String shoppingAddingDetail(String list, int count) {
    return 'Enviando $count artículos a «$list»';
  }

  @override
  String get shoppingErrorRetainNotice => 'Tu selección se ha conservado';

  @override
  String get shoppingTryAgain => 'Reintentar';

  @override
  String get shoppingBack => 'Atrás';

  @override
  String get cameraTitle => 'Registro con cámara';

  @override
  String get cameraDropZoneTitle => 'Suelta fotos o haz clic para seleccionar';

  @override
  String get cameraDropZoneBody => 'Añade hasta 10 fotos de tu nevera';

  @override
  String cameraAnalyzeButton(int n) {
    return 'Analizar $n foto(s) ⌘R';
  }

  @override
  String get cameraMaxPhotosHint =>
      'Puedes añadir hasta 10 fotos. Las fotos de más se omitieron.';

  @override
  String get cameraAnalyzingTitle => 'La IA está analizando tus fotos…';

  @override
  String get cameraAnalyzingBody =>
      'Reconociendo ingredientes. Espera un momento.';

  @override
  String cameraReviewHeader(int n) {
    return 'Ingredientes detectados ($n artículos)';
  }

  @override
  String get cameraConfHighLabel => 'Alta';

  @override
  String get cameraConfMidLabel => 'Media';

  @override
  String get cameraConfLowLabel => 'Baja';

  @override
  String cameraConfirmButton(int n) {
    return 'Añadir seleccionados ($n artículos)';
  }

  @override
  String get cameraEditNameLabel => 'Nombre';

  @override
  String get cameraEditQtyLabel => 'Cantidad';

  @override
  String get cameraEditUnitLabel => 'Unidad';

  @override
  String get cameraEditCategoryLabel => 'Categoría';

  @override
  String get cameraErrorNetworkTitle => 'No se pudieron analizar las fotos';

  @override
  String get cameraErrorNetworkBody =>
      'Muévete a una zona con mejor señal o conéctate a Wi-Fi.';

  @override
  String get cameraErrorNoApiKeyTitle => 'No hay clave de API registrada';

  @override
  String get cameraErrorNoApiKeyBody =>
      'Ve a Ajustes y añade una clave de API para activar el reconocimiento por IA.';

  @override
  String get cameraErrorNoVisionTitle =>
      'Este proveedor no admite el reconocimiento de imágenes';

  @override
  String get cameraErrorNoVisionBody =>
      'Cambia a un proveedor con reconocimiento de imágenes en Ajustes.';

  @override
  String get cameraErrorRetry => 'Reintentar';

  @override
  String get cameraErrorOpenSettings => 'Abrir Ajustes';

  @override
  String cameraAddedToast(int n) {
    return 'Se añadieron $n artículos al inventario';
  }

  @override
  String get cameraMobileCaptureTitle => 'Fotografía tu nevera';

  @override
  String get cameraMobileAddPhotos => 'Añadir fotos';

  @override
  String cameraMobilePhotoCount(int n) {
    return '$n / 10';
  }

  @override
  String cameraMobileAnalyzeButton(int n) {
    return 'Analizar $n foto(s)';
  }

  @override
  String get cameraMobileReviewTitle => 'Ingredientes detectados';

  @override
  String cameraMobileReviewSummary(int total, int chosen) {
    return '$total candidatos · $chosen seleccionados';
  }

  @override
  String get cameraMobileReviewHint =>
      'Selecciona los artículos que quieres conservar y ajusta el nombre, la cantidad o la categoría según necesites';

  @override
  String get cameraMobileReviewFootnote =>
      'La IA leyó estos candidatos automáticamente. Puedes revisarlos antes de añadirlos.';

  @override
  String get cameraMobileErrorLater => 'Analizar más tarde';

  @override
  String get onboardingRailTitle => 'Asistente de configuración';

  @override
  String get onboardingStep0 => 'Bienvenida';

  @override
  String get onboardingStep1 => 'Elegir IA';

  @override
  String get onboardingStep2 => 'Recordatorios';

  @override
  String get onboardingStep3 => 'Elegir lista';

  @override
  String get onboardingStep4 => 'Electrodomésticos';

  @override
  String get onboardingStep5 => 'Listo';

  @override
  String get onboardingWelcomeTitle => 'Te damos la bienvenida a Tsukaikiri';

  @override
  String get onboardingWelcomeSub =>
      'Registra los ingredientes de tu nevera y recibe sugerencias de comidas para aprovecharlos.\nEmpecemos con una configuración rápida.';

  @override
  String get onboardingWelcomeFeature1Title => 'Registra con una foto';

  @override
  String get onboardingWelcomeFeature1Body =>
      'Añade ingredientes en lote con tu cámara';

  @override
  String get onboardingWelcomeFeature2Title => 'Comidas para aprovechar';

  @override
  String get onboardingWelcomeFeature2Body =>
      'Prioriza los ingredientes que caducan antes';

  @override
  String get onboardingWelcomeFeature3Title => 'Lista de la compra';

  @override
  String get onboardingWelcomeFeature3Body =>
      'Añade automáticamente lo que falta a Recordatorios';

  @override
  String get onboardingWelcomeStart => 'Empezar';

  @override
  String get onboardingAiTitle => 'La IA ya está lista';

  @override
  String get onboardingAiSub =>
      'La IA funciona en tu dispositivo, así que no necesitas clave de API.';

  @override
  String onboardingAiOnDeviceReady(String name) {
    return '$name funciona en tu dispositivo: gratis, sin clave de API y sin conexión. Nada sale de tu dispositivo.';
  }

  @override
  String get onboardingAiOnDeviceMissing =>
      'La IA en el dispositivo no está disponible aquí. Más tarde puedes añadir tu propia clave de API en Ajustes → IA para usar la IA en la nube.';

  @override
  String get onboardingAiSkip => 'Configurar más tarde';

  @override
  String get onboardingAiKeyLabel => 'Clave de API';

  @override
  String onboardingAiGetKeyLink(String provider) {
    return 'Obtener clave de API de $provider';
  }

  @override
  String get onboardingAiSelected => 'Seleccionado';

  @override
  String get onboardingLinkTitle => 'Conectar Recordatorios';

  @override
  String get onboardingLinkSub =>
      'Los ingredientes que falten se añadirán automáticamente a Recordatorios de macOS.';

  @override
  String get onboardingLinkSkip => 'Más tarde';

  @override
  String get onboardingLinkApp => 'App';

  @override
  String get onboardingLinkAppValue => 'Recordatorios (macOS)';

  @override
  String get onboardingLinkAction => 'Puede hacer';

  @override
  String get onboardingLinkActionValue =>
      'Añadir artículos a una lista de la compra';

  @override
  String get onboardingLinkPrivacy => 'Privacidad';

  @override
  String get onboardingLinkPrivacyValue =>
      'Las fotos se procesan solo en este Mac';

  @override
  String get onboardingLinkButton => 'Permitir acceso a Recordatorios';

  @override
  String get onboardingLinkDone => 'Conectado a Recordatorios';

  @override
  String get onboardingLinkError =>
      'No se pudo acceder a Recordatorios. Puedes configurarlo más tarde en Ajustes.';

  @override
  String get onboardingListTitle => 'Elige una lista de destino';

  @override
  String get onboardingListSub =>
      'Selecciona la lista de Recordatorios donde se añadirán los artículos de la compra.';

  @override
  String get onboardingListSkip => 'Más tarde';

  @override
  String get onboardingListNewName => 'Nombre de la nueva lista…';

  @override
  String get onboardingListCreate => 'Crear';

  @override
  String get onboardingListLoading => 'Cargando…';

  @override
  String get onboardingApplianceTitle => 'Registra tus electrodomésticos';

  @override
  String get onboardingApplianceSub =>
      'Selecciona los electrodomésticos que tienes para recetas personalizadas.';

  @override
  String get onboardingApplianceSkip => 'No tengo ninguno';

  @override
  String get onboardingApplianceSeries => 'Serie';

  @override
  String get onboardingFinishTitle => '¡Todo listo!';

  @override
  String get onboardingFinishSub =>
      'Registra los ingredientes de tu nevera y empieza a recibir sugerencias de comidas para aprovecharlos.';

  @override
  String get onboardingFinishAiLabel => 'IA';

  @override
  String get onboardingFinishListLabel => 'Lista de Recordatorios';

  @override
  String get onboardingFinishApplianceLabel => 'Electrodomésticos';

  @override
  String get onboardingFinishNotSet => 'Sin configurar';

  @override
  String get onboardingFinishSettingsNote =>
      'Puedes cambiar estos ajustes en cualquier momento en la pantalla de Ajustes.';

  @override
  String get onboardingFinishStart => 'Registrar ingredientes y empezar';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get helpTitle => 'Ayuda / Acerca de';

  @override
  String get helpAppTagline =>
      'Una app que te ayuda a aprovechar los ingredientes de la nevera sugiriéndote comidas para gastarlos.';

  @override
  String get helpGuideEyebrow => 'GUÍA';

  @override
  String get helpGuideTitle => 'Cómo usarla';

  @override
  String get helpStep1Title => 'Registra ingredientes';

  @override
  String get helpStep1Body =>
      'Haz una foto de tu nevera y la IA reconocerá los ingredientes para añadirlos a tu inventario. También puedes añadirlos manualmente.';

  @override
  String get helpStep2Title => 'Revisa el inventario y la caducidad';

  @override
  String get helpStep2Body =>
      'Los ingredientes se ordenan por fecha de caducidad. Los que caducan pronto se muestran en naranja; los vencidos en rojo.';

  @override
  String get helpStep3Title => 'Recibe sugerencias de comidas';

  @override
  String get helpStep3Body =>
      'Recibe ideas de comidas para aprovechar tu inventario actual. Se incluyen recetas adaptadas a tus electrodomésticos.';

  @override
  String get helpStep4Title => 'Añade lo que falta a la lista de la compra';

  @override
  String get helpStep4Body =>
      'Los ingredientes que necesitas para las comidas elegidas se añaden en lote a tu lista de la compra de Recordatorios.';

  @override
  String get helpAiEyebrow => 'IA';

  @override
  String get helpAiTitle => 'Acerca de la IA';

  @override
  String get helpAiBody1 =>
      'Tsukaikiri usa IA para las sugerencias de comidas y el reconocimiento de ingredientes. En dispositivos compatibles, la IA funciona en tu dispositivo (on-device): gratis, sin clave de API y sin conexión.';

  @override
  String get helpAiBody2 =>
      'Si quieres sugerencias más inteligentes, puedes registrar tu propia clave de API (Gemini, OpenAI, Claude, etc.) en Ajustes → IA para cambiar a un modelo en la nube más avanzado.';

  @override
  String get helpAiCalloutTitle => 'Privacidad';

  @override
  String get helpAiCalloutBody =>
      'Al usar la IA en el dispositivo, tus fotos y tu inventario se procesan en el dispositivo y no se envían a ningún sitio.';

  @override
  String get helpDataEyebrow => 'DATOS';

  @override
  String get helpDataTitle => 'Sobre los datos de caducidad';

  @override
  String get helpDataP1 =>
      'Las pautas de caducidad de esta app se basan en el conjunto de datos FoodKeeper publicado por el Servicio de Inocuidad e Inspección de los Alimentos (FSIS) del USDA. FoodKeeper es un conjunto de datos oficial que resume los periodos de conservación recomendados para diversos alimentos.';

  @override
  String get helpDataP2 =>
      'Los alimentos no incluidos en FoodKeeper —como los ingredientes propios de Japón— se complementan con pautas de conservación investigadas de forma independiente.';

  @override
  String get helpDataCalloutTitle =>
      'Las fechas mostradas son solo estimaciones';

  @override
  String get helpDataCalloutBody =>
      'La duración real varía según las condiciones de conservación, si el envase se ha abierto y la estación del año. Comprueba siempre el estado de los alimentos por ti mismo.';

  @override
  String get helpSourceTitle => 'Fuentes y referencias';

  @override
  String get helpSourceFoodkeeperTitle => 'FoodKeeper';

  @override
  String get helpSourceFoodkeeperDesc =>
      'Pautas de conservación de alimentos de USDA / FSIS';

  @override
  String get helpSourceDatagovTitle => 'Data.gov (datos de FoodKeeper)';

  @override
  String get helpSourceDatagovDesc =>
      'Catálogo de datos abiertos del Gobierno de EE. UU.';

  @override
  String get helpEditCalloutTitle =>
      'Puedes editar las fechas de caducidad en cualquier momento';

  @override
  String get helpEditCalloutBody =>
      'Abre la vista de detalle de cualquier ingrediente para actualizar su fecha de caducidad. Sobrescríbela con la fecha del envase o tu propio criterio.';

  @override
  String get helpLegalTitle => 'Aviso legal y privacidad';

  @override
  String get helpLegalTerms => 'Condiciones de uso';

  @override
  String get helpLegalPrivacy => 'Política de privacidad';

  @override
  String get helpLegalFaq => 'Preguntas frecuentes y soporte';

  @override
  String get helpFooter =>
      'Datos de FoodKeeper © USDA / FSIS (Dominio público)\n© 2026 Tsukaikiri';
}
