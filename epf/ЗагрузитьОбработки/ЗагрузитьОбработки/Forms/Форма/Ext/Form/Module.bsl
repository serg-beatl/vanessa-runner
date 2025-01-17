﻿&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	МожноЗавершатьРаботу = Ложь;
	ПараметрЗапускаФормы = ПараметрЗапуска;
	
	Если Не ПустаяСтрока(ПараметрЗапускаФормы) Тогда
		ЗапуститьОбработчикиОжидания();
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьОбработчикиОжидания()
  	МассивПараметров = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(ПараметрЗапускаФормы, ";");

	Путь = МассивПараметров[0];
	ПутьКЛогам = МассивПараметров[1];

	ТекстСообщения = СтрШаблон("%1: Начало работы", ОбщегоНазначенияКлиент.ДатаСеанса());
	КонечныйАвтомат("ЗаписатьСообщение", ТекстСообщения);

	НеобходимоЗавершатьРаботу = (Найти(ПараметрЗапуска, "ЗавершитьРаботуСистемы;") > 0 ИЛИ НеобходимоЗавершатьРаботу);
	Если МассивПараметров.Количество() < 2 И НеобходимоЗавершатьРаботу Тогда
		МожноЗавершатьРаботу = Истина;
		Возврат;
	КонецЕсли; 
	
	ПодключитьОбработчикОжидания("ПодключитьЗагрузкуОбработки", 2, Истина);
	ПодключитьОбработчикОжидания("ПроверитьВозможностьЗакрытия", 5);

КонецПроцедуры

&НаКлиенте
Процедура ПроверитьВозможностьЗакрытия() Экспорт
	Если МожноЗавершатьРаботу И НеобходимоЗавершатьРаботу Тогда
		
		Сообщить("Завершаем работу");
		ЗавершитьРаботуСистемы(Ложь);                                             
		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьРезультатПодключения(ИмяФайла, Результат)
	
	Сообщить(Результат);
	
	Если ЗначениеЗаполнено(ИмяФайла) Тогда
		
		Попытка
			ТекстовыйДокумент = Новый ЗаписьТекста(ИмяФайла, ,,Истина);
			ТекстовыйДокумент.ЗаписатьСтроку(Результат);
			ТекстовыйДокумент.Закрыть();
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки; 

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПодключитьЗагрузкуОбработки() Экспорт 
	
	КаталогОбработок = Новый Файл(Путь);
	Контекст = Новый Структура;
	Контекст.Вставить("ДействиеОтсутствует", "ЗавершитьРаботу");
	Контекст.Вставить("ДействиеСуществует", "РекурсивнаяЗагрузка");
	Контекст.Вставить("Файл", КаталогОбработок.ПолноеИмя);
	
	КаталогОбработок.НачатьПроверкуСуществования(Новый ОписаниеОповещения("ПроверкаСуществованияФайла", ЭтотОбъект, Контекст)); 
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверкаСуществованияФайла(Существует = Ложь, ДополнительныеПараметры) Экспорт
	
	Если Существует Тогда

		КонечныйАвтомат(ДополнительныеПараметры["ДействиеСуществует"], ДополнительныеПараметры);
		
	Иначе 

		ТекстСообщения = СтрШаблон("%1: Не найден каталог: %2", ОбщегоНазначенияКлиент.ДатаСеанса(), ДополнительныеПараметры.Файл);
		КонечныйАвтомат("ЗаписатьСообщение", ТекстСообщения);

		КонечныйАвтомат(ДополнительныеПараметры["ДействиеОтсутствует"], ДополнительныеПараметры);

	КонецЕсли; 
		
КонецПроцедуры
	
&НаКлиенте
Процедура КонечныйАвтомат(Действие, ДополнительныеПараметры)
	Если Действие = "ЗавершитьРаботу" Тогда
		МожноЗавершатьРаботу = Истина;
		
		ТекстСообщения = СтрШаблон("%1: Окончание работы", ОбщегоНазначенияКлиент.ДатаСеанса());
		КонечныйАвтомат("ЗаписатьСообщение", ТекстСообщения);

		Возврат;

	ИначеЕсли Действие = "РекурсивнаяЗагрузка" Тогда
		ЗагрузкаВнешнихОбработок(ДополнительныеПараметры);
	ИначеЕсли Действие = "ЗаписатьСообщение" Тогда 
		ЗаписатьРезультатПодключения(ПутьКЛогам, ДополнительныеПараметры);
	ИначеЕсли Действие = "ЗаписатьОшибкуВЛог" Тогда 
		ЗаписатьРезультатПодключения(ПутьКЛогам, ДополнительныеПараметры);
	ИначеЕсли Действие = "ЗаписатьОшибкуВЛогИЗавершить" Тогда 
		ЗаписатьРезультатПодключения(ПутьКЛогам, ДополнительныеПараметры);
		КонечныйАвтомат("ЗавершитьРаботу", "");
	//ИначеЕсли Действие = "ЗагрузитьСписокФайлов" Тогда
	//	ЗагрузитьСписокФайлов(ДополнительныеПараметры);
	ИначеЕсли Действие = "ПроверитьКоличествоФайловКЗагрузкеИЗавершить" Тогда
		Если ДополнительныеПараметры = 0 Тогда
			КонечныйАвтомат("ЗавершитьРаботу", "");
		КонецЕсли; 
	КонецЕсли; 
		
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьКомандыРегламентныеЗадания(РезультатРегистрации, КомандыСохраненные = Неопределено)
	
	РезультатРегистрации.ОбъектСправочника.Команды.Сортировать("Представление");
	
	ВидДополнительнаяОбработка = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ВидДополнительныйОтчет = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет();
		
	Для Каждого ЭлементКоманда Из РезультатРегистрации.ОбъектСправочника.Команды Цикл
		
		Если РезультатРегистрации.ОбъектСправочника.Вид = Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительнаяОбработка
			И (ЭлементКоманда.ВариантЗапуска = Перечисления.СпособыВызоваДополнительныхОбработок.ВызовСерверногоМетода
			ИЛИ ЭлементКоманда.ВариантЗапуска = Перечисления.СпособыВызоваДополнительныхОбработок.СценарийВБезопасномРежиме) Тогда
			
			РегламентноеЗаданиеGUID = ЭлементКоманда.РегламентноеЗаданиеGUID;
			Если КомандыСохраненные <> Неопределено Тогда
				НайденнаяСтрока = КомандыСохраненные.Найти(ЭлементКоманда.Идентификатор, "Идентификатор");
				Если НайденнаяСтрока <> Неопределено Тогда
					РегламентноеЗаданиеGUID = НайденнаяСтрока.РегламентноеЗаданиеGUID;
				КонецЕсли;
			КонецЕсли;
			
			Если ЗначениеЗаполнено(РегламентноеЗаданиеGUID) Тогда
				ЭлементКоманда.РегламентноеЗаданиеGUID = РегламентноеЗаданиеGUID;
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры
 
&НаСервере
Функция ЗарегистрироватьОбработкуНаСервере(ПараметрыРегистрации)
	Перем Результат;
	Результат = "Успешно";  //По умолчанию успех.
	 
	//ПараметрыРегистрации.Вставить("КомандыСохраненные", Неопределено);
	// Вызов сервера
	РезультатРегистрации = ЗарегистрироватьОбработку(ПараметрыРегистрации);
	
	Если ПустаяСтрока(РезультатРегистрации.КраткоеПредставлениеОшибки) Тогда 

		// Обработка результата работы сервера
		Если РезультатРегистрации.Успех = Истина Тогда
			
			ЗаполнитьКомандыРегламентныеЗадания(РезультатРегистрации, РезультатРегистрации.КомандыСохраненные);

			РезультатРегистрации.ОбъектСправочника.ХранилищеОбработки = Новый ХранилищеЗначения(ПолучитьИзВременногоХранилища(ПараметрыРегистрации.АдресДанныхОбработки), Новый СжатиеДанных(9));
			РезультатРегистрации.ОбъектСправочника.Записать();
			Возврат Результат;

		КонецЕсли;
	Иначе 
		Результат = РезультатРегистрации.КраткоеПредставлениеОшибки;

		// Разбор причины отказа загрузки обработки и отображение информации пользователю
		Если РезультатРегистрации.ИмяОбъектаЗанято = Ложь Тогда

			// Причина отказа в КраткоеПредставлениеОшибки
			Результат = РезультатРегистрации.КраткоеПредставлениеОшибки;

		ИначеЕсли РезультатРегистрации.Конфликтующие.Конфликтующие.Количество() > 0 Тогда 

			// Представление занявших объектов
			КоличествоКонфликтующих = РезультатРегистрации.Конфликтующие.Количество();
			ПредставлениеЗанявших = "";
			Для Каждого ЭлементСписка Из РезультатРегистрации.Конфликтующие Цикл
				ПредставлениеЗанявших = ПредставлениеЗанявших
				+ ?(ПредставлениеЗанявших = "", "", ", ")
				+ СокрЛП(ЭлементСписка.Представление);
				Если СтрДлина(ПредставлениеЗанявших) > 80 Тогда
					ПредставлениеЗанявших = Лев(ПредставлениеЗанявших, 70)
					+ "... ("
					+ Формат(КоличествоКонфликтующих, "ЧН=0; ЧГ=")
					+ " "
					+ НСтр("ru = 'шт'")
					+ ")";
					Прервать;
				КонецЕсли;
			КонецЦикла;

			Результат = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Имя ""%1"" уже занято другими дополнительными отчетами (обработками):
					|%2.'"),
				РезультатРегистрации.ИмяОбъекта,
				ПредставлениеЗанявших
			);

		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
 КонецФункции

&НаСервере
Функция ЗарегистрироватьОбработку(ПараметрыРегистрации)

	СсылкаСправочника = Справочники.ДополнительныеОтчетыИОбработки.НайтиПоРеквизиту("ИмяФайла", ПараметрыРегистрации.ИмяФайла);
	Если СсылкаСправочника.Пустая() Тогда
		ОбъектСправочника = Справочники.ДополнительныеОтчетыИОбработки.СоздатьЭлемент();
		ОбъектСправочника.Заполнить(Неопределено);
		ОбъектСправочника.ИспользоватьДляФормыОбъекта = Истина;
		ОбъектСправочника.ИспользоватьДляФормыСписка  = Истина;
	Иначе
		ОбъектСправочника = СсылкаСправочника.ПолучитьОбъект();
	КонецЕсли;
	
	КомандыСохраненные = ОбъектСправочника.Команды.Выгрузить();

	Результат = ДополнительныеОтчетыИОбработки.ЗарегистрироватьОбработку(ОбъектСправочника, ПараметрыРегистрации);
	АдресРазрешений = ПоместитьВоВременноеХранилище(ОбъектСправочника.Разрешения.Выгрузить());

	Результат.Вставить("ОбъектСправочника", ОбъектСправочника);
	Результат.Вставить("КомандыСохраненные", КомандыСохраненные);

	Возврат Результат;

КонецФункции

&НаКлиенте
Процедура ЗагрузкаВнешнихОбработок(ДополнительныеПараметры)

	МассивРасширений = МассивРасширений();
		СостояниеПоискаФайлов.Очистить();

	Для каждого Расширение Из МассивРасширений Цикл
		
		СостояниеПоискаФайлов.Добавить(СтрШаблон(".%1", Расширение));
		
		ОповещениеЗагрузки = Новый ОписаниеОповещения("ОкончаниеЗагрузкиВнешнейОбработки", ЭтотОбъект, ДополнительныеПараметры);
		НачатьПомещениеФайловНаСервер(ОповещениеЗагрузки, 
			, 
			, 
			СтрШаблон("%1\%2\*.%3", ДополнительныеПараметры.Файл, Расширение, Расширение), 
			УникальныйИдентификатор);	
		
	КонецЦикла;

КонецПроцедуры 

&НаКлиенте
Процедура ОкончаниеЗагрузкиВнешнейОбработки(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт 
	
	Если ПомещенныеФайлы = Неопределено Тогда
		КонечныйАвтомат("ЗаписатьОшибкуВЛог", "Не удалось поместить в хранилище файлы из каталога " + ДополнительныеПараметры.Файл);
	Иначе
		Для каждого ОписаниеФайла Из ПомещенныеФайлы Цикл
			
			Если Не ОписаниеФайла.ПомещениеФайлаОтменено Тогда 
			
				ПараметрыРегистрации = ПараметрыРегистрации(ОписаниеФайла);		
				РезультатПодключения = ЗарегистрироватьОбработкуНаСервере(ПараметрыРегистрации);
				ТекстСообщения = СтрШаблон(
					"%1: Подключение %2: %3", 
					ОбщегоНазначенияКлиент.ДатаСеанса(), 
					ПараметрыРегистрации.ПолноеИмя, 
					РезультатПодключения);
					
				КонечныйАвтомат("ЗаписатьСообщение", ТекстСообщения);
                
			КонецЕсли;
			
			// нет возможности передать сюда обрабатываемое расширение через ДополнительныеПараметры, поэтому определяем так
			Расширение = ОписаниеФайла.СсылкаНаФайл.Расширение;
		
		КонецЦикла;
		
	КонецЕсли;
	
	ЭлементСписка = СостояниеПоискаФайлов.НайтиПоЗначению(Расширение);
	Если ЭлементСписка <> Неопределено Тогда
		СостояниеПоискаФайлов.Удалить(ЭлементСписка);
	КонецЕсли;
	
	КонечныйАвтомат("ПроверитьКоличествоФайловКЗагрузкеИЗавершить", СостояниеПоискаФайлов.Количество() + СписокФайловДляЗагрузки.Количество());
	
КонецПроцедуры

&НаКлиенте
Функция ПараметрыРегистрации(ОписаниеФайла)

	ЗначениеФункции = Новый Структура;
	
	ЗначениеФункции.Вставить("ИмяФайла", ОписаниеФайла.СсылкаНаФайл.Имя);
	ЗначениеФункции.Вставить("ПолноеИмя", ОписаниеФайла.СсылкаНаФайл.Файл.ПолноеИмя);
	ЗначениеФункции.Вставить("ЭтоОтчет", Неопределено);
	ЗначениеФункции.Вставить("ОтключатьКонфликтующие", Ложь);
	ЗначениеФункции.Вставить("ОтключатьПубликацию", Ложь);
	ЗначениеФункции.Вставить("Конфликтующие",  Новый СписокЗначений);
	ЗначениеФункции.Вставить("АдресДанныхОбработки", ОписаниеФайла.Адрес);
	
	РасширениеФайла = НРег(ОписаниеФайла.СсылкаНаФайл.Расширение);
	
	Если РасширениеФайла = ".erf" Тогда
		ЗначениеФункции.ЭтоОтчет = Истина;
	ИначеЕсли РасширениеФайла = ".epf" Тогда
		ЗначениеФункции.ЭтоОтчет = Ложь;
	КонецЕсли;
	
	Возврат ЗначениеФункции;
	
КонецФункции 

&НаКлиенте
Функция МассивРасширений() 

	ЗначениеФункции = Новый Массив;
	
	ЗначениеФункции.Добавить("epf");
	ЗначениеФункции.Добавить("erf");
	
	Возврат ЗначениеФункции;

КонецФункции 

&НаКлиенте
Процедура Запустить(Команда)
	ЗапуститьОбработчикиОжидания();
КонецПроцедуры

#Область УстаревшиеПроцедурыИФункции

//&НаКлиенте
//Процедура ОшибкаПоискаФайлов(ОписаниеОшибки = "", Параметр2, ДополнительныеПараметры) Экспорт
//	
//	Элемент = СостояниеПоискаФайлов.НайтиПоЗначению(ДополнительныеПараметры.МаскаПоиска);
//	Если Элемент <> Неопределено Тогда 
//		СостояниеПоискаФайлов.Удалить(Элемент);
//	КонецЕсли;
//	
//	КонечныйАвтомат("ПроверитьКоличествоФайловКЗагрузкеИЗавершить", СостояниеПоискаФайлов.Количество() + СписокФайловДляЗагрузки.Количество());
//	КонечныйАвтомат("ЗаписатьОшибкуВЛогИЗавершить", ОписаниеОшибки);	
//	
//КонецПроцедуры

//&НаКлиенте
//Процедура ОкончаниеПомещенияВнешнейОбработки(Результат, АдресДанныхОбработки, ВыбранноеИмяФайла, ПараметрыРегистрации) Экспорт
//		
//	Если Результат = Ложь Тогда
//		КонечныйАвтомат("ЗаписатьОшибкуВЛог", "Не удалось поместить в хранилище файл "+ ПараметрыРегистрации.ИмяФайла);
//	Иначе
//		 ПараметрыРегистрации.АдресДанныхОбработки = АдресДанныхОбработки;
//		 РезультатПодключения = ЗарегистрироватьОбработкуНаСервере(ПараметрыРегистрации);
//		 КонечныйАвтомат("ЗаписатьСообщение", "Подключение "+ВыбранноеИмяФайла + ": "+РезультатПодключения);
//	 КонецЕсли;
//	 
//	 Элемент = СписокФайловДляЗагрузки.НайтиПоЗначению(ПараметрыРегистрации.ПолноеИмя);
//	 Если Не Элемент = Неопределено Тогда
//		 СписокФайловДляЗагрузки.Удалить(Элемент);	 	
//	 КонецЕсли; 
//	 
//	 КонечныйАвтомат("ПроверитьКоличествоФайловКЗагрузкеИЗавершить", СостояниеПоискаФайлов.Количество() + СписокФайловДляЗагрузки.Количество());
//	
// КонецПроцедуры

// &НаКлиенте
//Процедура ЗагрузитьСписокФайлов(НайденныеФайлы)
//	
//	//Найденные файлы загружаем в список значений.
//	Для каждого Элемент Из НайденныеФайлы Цикл
//		СписокФайловДляЗагрузки.Добавить(Элемент.ПолноеИмя);
//	КонецЦикла;
//	
//	МассивЭлементовДляУдалиения = Новый Массив();
//	СписокДляОбхода = СписокФайловДляЗагрузки.Скопировать();
//	Для каждого ЭлементСписка Из СписокДляОбхода Цикл
//		
//		ИмяФайла = ЭлементСписка.Значение;
//		
//		ПараметрыРегистрации = Новый Структура;
//		ПараметрыРегистрации.Вставить("ИмяФайла", "");
//		ПараметрыРегистрации.Вставить("ПолноеИмя", ИмяФайла);
//		ПараметрыРегистрации.Вставить("ЭтоОтчет", Неопределено);
//		ПараметрыРегистрации.Вставить("ОтключатьКонфликтующие", Ложь);
//		ПараметрыРегистрации.Вставить("ОтключатьПубликацию", Ложь);
//		ПараметрыРегистрации.Вставить("Конфликтующие",  Новый СписокЗначений);
//		ПараметрыРегистрации.Вставить("АдресДанныхОбработки", "");
//				
//		ФайлОбработки = Новый Файл(ИмяФайла);
//		ПараметрыРегистрации.ИмяФайла = ФайлОбработки.Имя;
//		РасширениеФайла = ВРег(ФайлОбработки.Расширение);
//		Если РасширениеФайла = ".ERF" Тогда
//			ПараметрыРегистрации.ЭтоОтчет = Истина;
//		ИначеЕсли РасширениеФайла = ".EPF" Тогда
//			ПараметрыРегистрации.ЭтоОтчет = Ложь;
//		КонецЕсли;

//		НачатьПомещениеФайла(Новый ОписаниеОповещения("ОкончаниеПомещенияВнешнейОбработки", ЭтотОбъект, ПараметрыРегистрации), ,ИмяФайла,Ложь, УникальныйИдентификатор);
//		
//	КонецЦикла; 
//		
//КонецПроцедуры

//&НаКлиенте
//Процедура ЗавершитьРаботуОжидание() Экспорт
//	ЗавершитьРаботуСистемы(Ложь);
//КонецПроцедуры

//Функция ЭтоФайлОтчетаИлиОбработки(Знач Файл)
//	РасширениеФайла = ВРег(Файл.Расширение);
//	Возврат РасширениеФайла = ".EPF" ИЛИ РасширениеФайла = ".ERF";

//КонецФункции
 
//&НаКлиенте
//Процедура РезультатПоискаФайлов(НайденныеФайлы, ДополнительныеПараметры) Экспорт
//	
//	КонечныйАвтомат(ДополнительныеПараметры.Действие, НайденныеФайлы);
//	
//	Элемент = СостояниеПоискаФайлов.НайтиПоЗначению(ДополнительныеПараметры.МаскаПоиска);
//	Если Элемент <> Неопределено Тогда 
//		СостояниеПоискаФайлов.Удалить(Элемент);
//	КонецЕсли;
//	
//	КонечныйАвтомат("ПроверитьКоличествоФайловКЗагрузкеИЗавершить", СостояниеПоискаФайлов.Количество() + СписокФайловДляЗагрузки.Количество());
//		
//КонецПроцедуры //РезультатПоискаФайлов
 
//&НаКлиенте
//Процедура РекурсивнаяЗагрузкаВнешнихОбработок(ДополнительныеПараметры)
//	Перем СписокМасокФайлов;
//	Перем Элемент;
//	Перем Контекст;
//	
//	СостояниеПоискаФайлов.Очистить();
//	СостояниеПоискаФайлов.Добавить("*.epf");
//	СостояниеПоискаФайлов.Добавить("*.erf");
//	
//	СписокМасокФайлов = СостояниеПоискаФайлов.Скопировать();
//	Для каждого Элемент Из СписокМасокФайлов Цикл
//		Контекст = Новый Структура;
//		Контекст.Вставить("Действие", "ЗагрузитьСписокФайлов");
//		Контекст.Вставить("Файл", ДополнительныеПараметры.Файл);
//		Контекст.Вставить("МаскаПоиска", Элемент.Значение);
//		
//		НачатьПоискФайлов(Новый ОписаниеОповещения("РезультатПоискаФайлов", ЭтотОбъект, Контекст, "ОшибкаПоискаФайлов", ЭтотОбъект), Контекст.Файл, Контекст.МаскаПоиска, Истина);
//		
//	КонецЦикла; 
//		
//КонецПроцедуры 

#КонецОбласти