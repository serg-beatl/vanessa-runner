#Использовать logos
#Использовать tempfiles
#Использовать fs

Перем Лог;

Функция ПодключитьРаннер() Экспорт // TODO удалить  метод после рефакторинга
	Путь = ОбъединитьПути(ОбщиеМетоды.КаталогПроекта(), "tools", "runner.os");
	ПодключитьСценарий(Путь, "runner");
	runner = Новый runner();
	Возврат runner;
КонецФункции

Функция ЗапуститьПроцесс(Знач СтрокаВыполнения) Экспорт
	Перем ПаузаОжиданияЧтенияБуфера;
	
	ПаузаОжиданияЧтенияБуфера = 10;
	
	Лог = ПолучитьЛог();
	Лог.Отладка(СтрокаВыполнения);
	Процесс = СоздатьПроцесс(СтрокаВыполнения,,Истина);
	Процесс.Запустить();
	
	ТекстБазовый = "";
	Счетчик = 0; МаксСчетчикЦикла = 100000;
	
	Пока Истина Цикл 
		Текст = Процесс.ПотокВывода.Прочитать();
		Лог.Отладка("Цикл ПотокаВывода "+Текст);
		Если Текст = Неопределено ИЛИ ПустаяСтрока(СокрЛП(Текст))  Тогда 
			Прервать;
		КонецЕсли;
		Счетчик = Счетчик + 1;
		Если Счетчик > МаксСчетчикЦикла Тогда 
			Прервать;
		КонецЕсли;
		ТекстБазовый = ТекстБазовый + Текст;
		
		sleep(ПаузаОжиданияЧтенияБуфера); //Подождем, надеюсь буфер не переполниться. 
		
	КонецЦикла;
	
	Процесс.ОжидатьЗавершения();
	
	Если Процесс.КодВозврата = 0 Тогда
		Текст = Процесс.ПотокВывода.Прочитать();
		Если Текст = Неопределено ИЛИ ПустаяСтрока(СокрЛП(Текст)) Тогда 

		Иначе
			ТекстБазовый = ТекстБазовый + Текст;
		КонецЕсли;
		Лог.Отладка(ТекстБазовый);
		Возврат ТекстБазовый;
	Иначе
		ВызватьИсключение "Сообщение от процесса 
		| код:" + Процесс.КодВозврата + " процесс: "+ Процесс.ПотокОшибок.Прочитать();
	КонецЕсли;	

КонецФункции

Функция ПрочитатьФайлИнформации(Знач ПутьКФайлу) Экспорт

	Текст = "";
	Файл = Новый Файл(ПутьКФайлу);
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеТекста(Файл.ПолноеИмя);
		Текст = Чтение.Прочитать();
		Чтение.Закрыть();
	Иначе
		Текст = "Информации об ошибке нет";
	КонецЕсли;

	Лог = ПолучитьЛог();
	Лог.Отладка("файл информации:
	|"+Текст);
	Возврат Текст;

КонецФункции

Функция ПолучитьИмяВременногоФайлаВКаталоге(Знач Каталог, Знач Расширение = "") Экспорт
	ПревКаталог = ВременныеФайлы.БазовыйКаталог;
	ВременныеФайлы.БазовыйКаталог = Каталог;
	ИмяВременногоФайла = ВременныеФайлы.НовоеИмяФайла(Расширение);
	ВременныеФайлы.БазовыйКаталог = ПревКаталог;
	Возврат ИмяВременногоФайла;
КонецФункции

Процедура ОбеспечитьПустойКаталог(Знач ФайлОбъектКаталога) Экспорт

	//TODO заменить ОбщиеМетоды.ОбеспечитьПустойКаталог на ФС.ОбеспечитьПустойКаталог
	ФС.ОбеспечитьПустойКаталог(ФайлОбъектКаталога.ПолноеИмя);
	
КонецПроцедуры

Функция ОбернутьПутьВКавычки(Знач Путь) Экспорт

	Результат = Путь;
	Если Прав(Результат, 1) = "\" Тогда
		Результат = Лев(Результат, СтрДлина(Результат) - 1);
	КонецЕсли;

	Результат = """" + Результат + """";

	Возврат Результат;

КонецФункции

Функция УбратьКавычкиВокругПути(Знач Путь) Экспорт
	//NOTICE: https://github.com/xDrivenDevelopment/precommit1c 
	//Apache 2.0 
	ОбработанныйПуть = Путь;

	Если Лев(ОбработанныйПуть, 1) = """" Тогда
		ОбработанныйПуть = Прав(ОбработанныйПуть, СтрДлина(ОбработанныйПуть) - 1);
	КонецЕсли;
	Если Прав(ОбработанныйПуть, 1) = """" Тогда
		ОбработанныйПуть = Лев(ОбработанныйПуть, СтрДлина(ОбработанныйПуть) - 1);
	КонецЕсли;
	
	Возврат ОбработанныйПуть;
	
КонецФункции

Функция ПолныйПуть(Знач Путь, Знач КаталогПроекта = "") Экспорт
	Перем ФайлПуть;
	
	Если ПустаяСтрока(Путь) Тогда 
		Возврат Путь;
	КонецЕсли;

	Если ПустаяСтрока(КаталогПроекта) Тогда
		КаталогПроекта = ПараметрыСистемы.КорневойПутьПроекта;
	КонецЕсли;

	Если Лев(Путь, 1) = "." Тогда 
		Путь = ОбъединитьПути(КаталогПроекта, Путь);
	КонецЕсли;
	
	ФайлПуть = Новый Файл(Путь);

	Возврат ФайлПуть.ПолноеИмя
	
КонецФункции //ПолныйПуть()

// Возвращает путь файла относительно корневого каталога
//
// Параметры:
//   ПутьКорневогоКаталога - <Строка> - путь корневого каталога
//   ПутьВнутреннегоФайла - <Строка> - путь файла
//
//  Возвращаемое значение:
//   <Строка> - относительный путь файла
//
Функция ОтносительныйПуть(Знач ПутьКорневогоКаталога, Знач ПутьВнутреннегоФайла) Экспорт
	//TODO отрефакторить различие параметров (по порядку) между ПолныйПуть и ОтносительныйПуть
	//TODO перенести в библиотеку fs методы ПолныйПуть и ОтносительныйПуть

	Если ПустаяСтрока(ПутьКорневогоКаталога) Тогда	
		Возврат "";
	КонецЕсли;
	
	ФайлКорень = Новый Файл(ПутьКорневогоКаталога);
	ФайлВнутреннийКаталог = Новый Файл(ПутьВнутреннегоФайла);
	Рез = СтрЗаменить(ФайлВнутреннийКаталог.ПолноеИмя, ФайлКорень.ПолноеИмя, "");
	Если Найти("\/", Лев(Рез, 1)) > 0 Тогда
		Рез = Сред(Рез, 2);
	КонецЕсли;
	Если Найти("\/", Прав(Рез, 1)) > 0 Тогда
		Рез = Лев(Рез, СтрДлина(Рез)-1);
	КонецЕсли;

	Возврат Рез;
КонецФункции

Функция КаталогПроекта() Экспорт
	ФайлИсточника = Новый Файл(ТекущийСценарий().Источник);
	Возврат ОбъединитьПути(ФайлИсточника.Путь, "..", "..");
КонецФункции

Функция ПолучитьЛог()
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецЕсли;
	Возврат Лог;	
КонецФункции

Функция ТипФайлаПоддерживается(Знач Файл) Экспорт
	Если ПустаяСтрока(Файл.Расширение) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Поз = Найти(".epf,.erf,", Файл.Расширение+",");
	Возврат Поз > 0;
	
КонецФункции

// из-за особенностей загрузки модуль ОбщиеМетоды грузится раньше ПараметрыСистемы, 
//поэтому сразу в конце кода модуля использовать ПараметрыСистемы нельзя
