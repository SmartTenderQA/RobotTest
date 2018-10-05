# coding=utf-8
from munch import munchify as smarttender_munchify
from iso8601 import parse_date
from dateutil.parser import parse
from dateutil.parser import parserinfo
from pytz import timezone
import urllib2
import os
import re
import requests
import json
import ast


def get_tender_data(link):
    r = requests.get(link).text
    # s = r.replace('true', 'True')
    # dictionary = ast.literal_eval(s)
    return r


TZ = timezone(os.environ['TZ'] if 'TZ' in os.environ else 'Europe/Kiev')
number_of_tabs = 1


def tender_field_info(field):
    if "items" in field:
        list = re.search('(?P<items>\w+)\[(?P<id>\d)\]\.(?P<map>.+)', field)
        item_id = int(list.group('id')) + 1
        result = list.group('map')
        map = {
            "description": "xpath=(//*[@data-qa='value-list']/div/div[contains(@class,'lot')])[{0}]",
            "deliveryDate.startDate": "xpath=(//*[@data-qa='date-start'])[{0}]",
            "deliveryDate.endDate": "xpath=(//*[@data-qa='date-end'])[{0}]",
            "deliveryLocation.latitude": "xpath=(//*[@data-qa='value-list']//a)[{0}]@href",
            "deliveryLocation.longitude": "xpath=(//*[@data-qa='value-list']//a)[{0}]@href",
            "classification.scheme": "xpath=(//*[@data-qa='value-list'])[{0}]//div[@class='nomenclature'][1]",
            "classification.id": "xpath=(//*[@data-qa='value-list'])[{0}]//div[@class='nomenclature'][1]",
            "classification.description": "xpath=(//*[@data-qa='value-list'])[{0}]//div[@class='nomenclature'][1]",
            "unit.name": "xpath=(//*[@data-qa='value-list']//div[2]/div[2])[{0}]",
            "unit.code": "xpath=(//*[@data-qa='value-list']//div[2]/div[2])[{0}]",
            "quantity": "xpath=(//*[@data-qa='value-list']//div[2]/div[2])[{0}]",
            "additionalClassifications[0].scheme": "xpath=(//*[@data-qa='value-list'])[{0}]//div[@class='nomenclature'][2]",
            "additionalClassifications[0].id": "xpath=(//*[@data-qa='value-list'])[{0}]//div[@class='nomenclature'][2]",
            "additionalClassifications[0].description": "xpath=(//*[@data-qa='value-list'])[{0}]//div[@class='nomenclature'][2]",
            "deliveryAddress.countryName": "xpath=(//div[@id='tooltipID']//td[@class='smaller-font']//div[4])[{0}]",
            "deliveryAddress.postalCode": "xpath=(//div[@id='tooltipID']//td[@class='smaller-font']//div[4])[{0}]",
            "deliveryAddress.region": "xpath=(//div[@id='tooltipID']//td[@class='smaller-font']//div[4])[{0}]",
            "deliveryAddress.locality": "xpath=(//div[@id='tooltipID']//td[@class='smaller-font']//div[4])[{0}]",
            "deliveryAddress.streetAddress": "xpath=(//div[@id='tooltipID']//td[@class='smaller-font']//div[4])[{0}]",
        }
        return map[result].format(item_id)
    elif "lots" in field:
        list = re.search('(?P<lots>\w+)\[(?P<id>\d)\]\.(?P<map>.+)', field)
        lot_id = int(list.group('id')) + 1
        result = list.group('map')
        map = {
            "minimalStep.valueAddedTaxIncluded": "xpath=//*[@class='budget']",
            "minimalStep.amount": "xpath=//*[@data-qa='budget-min-step']/div[2]//span[4]",
            "minimalStep.currency": "xpath=//*[@data-qa='budget-min-step']/div[2]//span[5]",
        }
        return map[result].format(lot_id)
    elif "features" in field:
        list = re.search('(?P<features>\w+)\[(?P<id>\d)\]\.(?P<map>.+)', field)
        features_id = int(list.group('id')) + 1
        result = list.group('map')
        map = {
            "title": "xpath=(//*[@data-qa='feature-header']//div[@class='expander-title'][1])[{0}]",
            "description": "xpath=(//*[@class='feature-description'])[{0}]",
            "featureOf": "xpath=//*[contains(text(), '{0}')]/ancestor::div[@data-qa='lot-features']/div[1]",
        }
        return map[result].format(features_id)
    elif "questions" in field:
        question_id = int(re.search("\d", field).group(0))
        result = ''.join(re.split(r'].', ''.join(re.findall(r'\]\..+', field))))
        map = {
            "title": "xpath=(//*[@data-qa='questions']//*[@class='bold break-word'])[{0}+1]",
            "description": "xpath=(//*[@data-qa='questions']//*[@class='bold break-word']/following-sibling::div[1])[{0}+1]",
            "answer": "xpath=(//*[@data-qa='questions']//*[@class='break-word card-padding'])[{0}+1]"
        }
        return (map[result]).format(question_id)
    elif "awards" in field:
        list = re.search('(?P<documents>\w+)\[(?P<id>\d)\]\.(?P<map>.+)', field)
        award_id = int(list.group('id')) + 1
        result = list.group('map')
        map = {
            # "status": "css=div#auctionResults div.row.well:nth-child({0}) h5",
            "status": "xpath=(//*[@data-qa='qualification-info']/div[3]/div[2])[{0}]",
            "documents[0].title": "xpath=(//*[contains(@class,'filename')]//a/span)[{0}]",
            "suppliers[0].contactPoint.telephone": "xpath=//table[@class='table-proposal'][{0}]//td[1]/div/div[4]/span",
            "suppliers[0].contactPoint.name": "xpath=//table[@class='table-proposal'][{0}]//td[1]/div/div[2]/span",
            "suppliers[0].contactPoint.email": "xpath=//table[@class='table-proposal'][{0}]//td[1]/div/div[3]/span",
            "suppliers[0].identifier.legalName": "xpath=(//*[@data-qa='qualification-info']//div[@class='expander-title'])[{0}]",
            "suppliers[0].identifier.id": "xpath=//table[@class='table-proposal'][{0}]//td[1]/div/div[1]/span",
            "suppliers[0].name": "xpath=(//*[@data-qa='qualification-info']//div[@class='expander-title'])[{0}]",
            "value.amount": "xpath=(//*[@data-qa='qualification-info']/div[2]/div[2])[{0}]",
            "value.currency": "xpath=//*[@data-qa='qualification-block']//*[@data-qa='captions']/div[2]",
            "complaintPeriod.endDate": "css=span",
        }
        return map[result].format(award_id)
    elif "documents" in field:
        list = re.search('(?P<documents>\w+)\[(?P<id>\d)\]\.(?P<map>.+)', field)
        document_id = int(list.group('id')) + 1
        result = list.group('map')
        map = {
            "title": "xpath=//*[@data-qa='documents-block']//span",
        }
        return map[result].format(document_id)
    elif "funders" in field:
        map = {
            "funders[0].name": "xpath=(//*[@class='group-element-value-1'])[5]",
        }
    else:
        map = {
            "title": "xpath=//*[@data-qa='header-block']//*[@data-qa='title']",
            "title_en": "css=.info_orderItem",
            "title_ru": "css=.info_orderItem",
            "description": "xpath=//*[@data-qa='header-block']//*[@data-qa='description']",
            "description_en": "css=.info_info_comm2",
            "value.amount": "xpath=//*[@class='budget']",
            "value.currency": "xpath=//*[@class='budget']",
            "value.valueAddedTaxIncluded": "xpath=//*[@class='budget']",
            "tenderID": "xpath=//*[@data-qa='prozorro-number']/div[2]//span",
            "procuringEntity.name": "xpath=//*[@data-qa='organizer-block']/div[2]/div[2]/span",
            "enquiryPeriod.startDate": "xpath=//*[@data-qa='enquiry-period']//*[@data-qa='date-start']",
            "enquiryPeriod.endDate": "xpath=//*[@data-qa='enquiry-period']//*[@data-qa='date-end']",
            "tenderPeriod.startDate": "xpath=//*[@data-qa='tendering-period']//*[@data-qa='date-start']",
            "tenderPeriod.endDate": "xpath=//*[@data-qa='tendering-period']//*[@data-qa='date-end']",
            "minimalStep.amount": "xpath=//*[@data-qa='budget-min-step']/div[2]//span[4]",
            "status": "xpath=//*[@data-qa='status']",
            "qualificationPeriod.endDate": u"xpath=(//*[@data-qa='time-line']//*[contains(.,'Прекваліфікація')])[1]/following-sibling::div[1]/div/div",
            "auctionPeriod.startDate": "xpath=//*[@data-qa='auction-start']/div[2]/span",
            "auctionPeriod.endDate": u"xpath=(//*[@data-qa='time-line']//*[contains(.,'Аукціон')])[1]/following-sibling::div[2]/div/div",
            "procurementMethodType": "xpath=//*[@data-qa='procedure-type']/div[2]/div",
            "guarantee.amount": "xpath=(//*[@class='table-responsive']//td[2])[3]",
            "minNumberOfQualifiedBids": "css=.info_minnumber_qualifiedbids",
            "dgfID": "css=.page-header h4:nth-of-type(2)",
            "auctionID": "css=.page-header h3:nth-of-type(3)",
            "tenderAttempts": "css=.page-header>div>h4",
            "procuringEntity.contactPoint.name": "xpath=//*[@data-qa='contactPerson-block']/*[@data-qa='name']/div[2]/span",
            "procuringEntity.contactPoint.telephone": "xpath=//*[@data-qa='contactPerson-block']/*[@data-qa='phone']/div[2]/a",
            "procuringEntity.identifier.legalName": "xpath=//*[@data-qa='organizer-block']/div[2]/div[2]/span",
            "procuringEntity.identifier.id": "xpath=//*[@data-qa='usreou']/div[2]/span",
            "procuringEntity.contactPoint.url": "css=.info_contact div:nth-child(2)",
            "lotValues[0].value.amount": "css=#lotAmount0>input",
            "cancellations[0].reason": "css=span.info_cancellation_reason",
            "cancellations[0].status": "css=span.info_cancellation_status",
            "eligibilityCriteria": "css=span.info_eligibilityCriteria",
            "contracts[0].status": "xpath=//*[@data-qa='qualification-info']//div[3]/div[2]",

            "procuringEntity.address.countryName": "css=td.smaller-font div:nth-child(4)",
            "procuringEntity.address.locality": "css=td.smaller-font div:nth-child(4)",
            "procuringEntity.address.postalCode": "css=td.smaller-font div:nth-child(4)",
            "procuringEntity.address.region": "css=td.smaller-font div:nth-child(4)",
            "procuringEntity.address.streetAddress": "css=span",

            "dgfDecisionID": "css=span.info_dgfDecisionId",
            "dgfDecisionDate": "css=span.info_dgfDecisionDate",

            "qualificationPeriod": "css=span",
            "causeDescription": "css=span",
            "cause": "css=span",
            "procuringEntity.identifier.scheme": "css=span",
            "complaintPeriod.endDate": "xpath=//*[@data-qa='enquiry-period']//*[@data-qa='date-end']",
        }
    return map[field]


def proposal_field_info(field):
    map = {
        "lotValues[0].value.amount": "css=#lotAmount0>input",
        "value.amount": "css=#lotAmount0>input",
        "status": "css=.ivu-alert-desc span",
    }
    return map[field]


def lot_field_info(field, id):
    map = {
        "title": "xpath=//*[@data-qa='header-block']//*[contains(text(), '{0}')]",
        "description": "xpath=//*[contains(text(), '{0}')]", #/ancestor::div[1]//*[@data-qa='description']
        "value.amount": "xpath=//*[@class='budget']",
        "value.currency": "xpath=//*[@class='budget']",
        "value.valueAddedTaxIncluded": "xpath=//*[@class='budget']",
        "minimalStep.amount": "xpath=//*[@data-qa='budget-min-step']/div[2]//span[4]",
        "minimalStep.currency": "xpath=//*[@data-qa='budget-min-step']/div[2]//span[5]",
        "minimalStep.valueAddedTaxIncluded": "xpath=//*[@class='budget']",
        "auctionPeriod.startDate": "xpath=//*[@data-qa='auction-start']/div[2]/span",
    }
    return map[field].format(id)


def item_field_info(field, id):
    map = {
        "description": "xpath=(//div[contains(text(), '{0}')])[1]",
        "unit.name": "xpath=//*[contains(text(), '{0}')]/following-sibling::td",
    }
    return map[field].format(id)


def non_price_field_info(field, id):
    map = {
        "title": "xpath=//*[contains(text(), '{0}')]",
        "description": "xpath=//*[contains(text(),'{0}')]/ancestor::div[2]//*[@class='feature-description']",
        "featureOf": "xpath=//*[contains(text(),'{0}')]/ancestor::div[contains(@data-qa,'-features') and not(contains(@data-qa,'list'))]/div[1]",
    }
    return map[field].format(id)


def document_fields_info(field, id):
    map = {
        "title": "xpath=//*[contains(text(), '{0}')]",
        "documentOf": "xpath=//*[contains(text(), '{0}')]",
        "description": "span.info_attachment_description:eq(0)",
        "content": "span.info_attachment_title:eq(0)",
        "type": "span.info_attachment_type:eq(0)",
    }
    return map[field].format(id)


def question_field_info(field, id):
    map = {
        "title": "xpath=//*[@class='ivu-row']//*[descendant::*[contains(text(), '{0}')]]/span",
        "description": "xpath=//*[@class='ivu-row']//*[descendant::*[contains(text(), '{0}')]]//div[@class='break-word']",
        "answer": "//*[contains(text(), '{0}')]/ancestor::*[@class='ivu-card-body']/div[3]",
    }
    return (map[field]).format(id)


def claim_field_info(field, title):
    map = {
        "title": u"""xpath=//*[contains(text(), "{0}")]/ancestor::*[@data-qa="complaint"]//*[@data-qa='title']//*[@class="break-word"]""",
        "status": u"""xpath=//*[contains(text(), "{0}")]/ancestor::*[@data-qa="complaint"]//*[contains(@class, 'complaint-status')]/span""",
        "description": u"""xpath=//*[contains(text(), "{0}")]/ancestor::*[@data-qa="complaint"]//*[@data-qa='description']/div/div[1]""",
        "cancellationReason": u"""xpath=//*[contains(text(), "{0}")]/ancestor::*[@data-qa='complaint']//*[@data-qa='events']//div[@class='content break-word']""",
        "resolutionType": u"xpath=//*[contains(text(), 'Тип рішення: ')]/span",
        "resolution": u"xpath=//*[contains(text(), 'Тип рішення: ')]/..//*[@class='content break-word']",
        "satisfied": u"xpath=//*[contains(text(), 'Участник дал ответ на решение организатора')]/../../..//*[@class='content break-word']",
    }
    return map[field].format(title)


def method_type_info(type):
    map = {
        "aboveThresholdUA": u"Відкриті торги",
    }
    return map[type]


def convert_claim_result_from_smarttender(value):
    map = {
        u"Вимога": "claim",
        u"Недійсна": 'invalid',
        u"Недійсне": 'invalid',
        u"Дана відповідь": "answered",
        u"Вирішена": "resolved",
        u"Вирішено": "resolved",
        u"Відхилена": 'cancelled',
        u"Не задоволена": "declined",
        u"Вимога задовільнена": True,
        u"Вимога не задовільнена": False,
        u"Залишено без розгляду": "ignored",
    }
    if value in map:
        result = map[value]
    else:
        result = value
    return result


def claim_file_field_info(field, doc_id):
    map = {
        "title": u"xpath=//*[contains(text(), '{0}')]",
    }
    return map[field].format(doc_id)


def convert_result(field, value):
    global ret
    if 'awards' in field and 'value.amount' in field:
        value = re.search(u'(?P<amount>[\d\s.]+).*', value).group('amount')
        ret = delete_spaces(value)
    elif "amount" in field:
        ret = re.search(u'(?P<amount>[\d\s.]+).*', value).group('amount')
        ret = float(ret.replace(' ', ''))
    elif "procurementMethodType" in field:
        if u"Оренда" in value:
            ret = 'dgfOtherAssets'
        elif u"для потреб оборони" in value:
            ret = 'aboveThresholdUA.defense'
        elif u"Конкурентний діалог" in value:
            ret = 'competitiveDialogueUA'
        elif u"Конкурентний діалог з публікацією англійською мовою" in value:
            ret = 'competitiveDialogueEU'
    elif "valueAddedTaxIncluded" in field:
        if u'ПДВ' in value:
            ret = True
        else:
            ret = value
    elif "currency" in field:
        if u'грн.' in value:
            ret = "UAH"
        else:
            ret = value
    elif "unit" in field or "quantity" in field:
        list = re.search(u'(?P<count>[\d,.]+?)\s(?P<name>.+)', value)
        if 'quantity' in field:
            ret = int(list.group('count'))
        else:
            ret = list.group('name')
        if 'code' in field:
            ret = convert_unit_from_smarttender_format(ret, 'code')
        elif 'name' in field:
            ret = convert_unit_from_smarttender_format(ret, 'name')
    elif "quantity" in field:
        ret = re.search(u'(?P<count>[\d,.]+?)\s(?P<name>.+)', value).group('count')
    elif "contractPeriod.startDate" in field \
            or "contractPeriod.endDate" in field \
            or "auctionPeriod.startDate" in field \
            or "auctionPeriod.endDate" in field:
        ret = convert_date(value)
    elif "qualificationPeriod.endDate" in field:
        list = re.search(u'(?P<data>[\d\.]+\s[\d\:]+)', value)
        ret = list.group('data')
        ret = convert_date(ret)
    elif "minNumberOfQualifiedBids" in field \
            or "tenderAttempts" in field:
        ret = int(value)
    elif "dgfDecisionDate" in field:
        ret = convert_date_offset_naive(value)
    elif "funders" in field:
        if u'Міжнародний банк реконструкції' in value:
            ret = 'World Bank'
    elif "quantity" in field:
        ret = re.search(u'(?P<count>[\d,.]+?)\s(?P<name>.+)', value).group('count')
    elif "lassification" in field:
        list = re.search(u'Код\s(?P<scheme>.+?):\s(?P<id>.+?)\s(?P<description>.+)', value)
        if 'scheme' in field:
            ret = list.group('scheme')
        elif 'id' in field:
            ret = list.group('id')
        elif 'description' in field:
            ret = list.group('description')
            if ret == u'Не визначено':
                ret = u'Не відображене в інших розділах'
    elif "status" in field or "awards." in field:
        ret = convert_tender_status(value)
    elif "enquiryPeriod.startDate" == field or "enquiryPeriod.endDate" == field or "tenderPeriod.startDate" == field \
            or "tenderPeriod.endDate" in field:
        value = str(''.join(re.findall(r"\d{2}.\d{2}.\d{4} \d{2}:\d{2}", value)))
        ret = convert_date(value)
    elif "deliveryDate.startDate" in field:
        #value = re.findall(u"\d{2}.\d{2}.\d{4}", value)
        #ret = value[0]
        ret = convert_date(value)
    elif "deliveryDate.endDate" in field:
        #value = re.findall(u"\d{2}.\d{2}.\d{4}", value)
        #ret = value[1]
        ret = convert_date(value)
    elif "deliveryLocation" in field:
        value = re.findall(r'\d{2}.\d+', value)
        if 'latitude' in field:
            ret = value[0]
        elif 'longitude' in field:
            ret = value[1]
    elif 'featureOf' in field:
        if u'Критерії до лоту' in value:
            ret = 'lot'
        elif u'Критерії до закупівлі' in value:
            ret = 'tenderer'
        elif u'Критерії до номенклатури' in value:
            ret = 'item'
        else:
            ret = False
    elif 'deliveryAddress' in field:
        list = re.search(
            u'Адреса постачання\: '
            u'(?P<postalCode>\d+?), (?P<countryName>.+?), (?P<region>.+?), (?P<locality>.+?), (?P<streetAddress>.+)',
            value)
        if 'postalCode' in field:
            ret = list.group('postalCode')
        elif 'countryName' in field:
            ret = list.group('countryName')
        elif 'region' in field:
            ret = list.group('region')
        elif 'locality' in field:
            ret = list.group('locality')
        elif 'streetAddress' in field:
            ret = list.group('streetAddress')
    else:
        ret = value
    return ret


def convert_unit_to_smarttender_format(unit):
    map = {
        u"кілограми": u"кг",
        u"послуга": u"умов.",
        u"умов.": u"умов.",
        u"усл.": u"умов.",
        u"метри квадратні": u"м.кв.",
        u"м.кв.": u"м.кв.",
        u"шт": u"шт",
        u"набір": u"набір",
        u"Флакон": u"флак.",
        u"упаковка": u"упаков",
        u"штуки": u"штуки",
        u"лот": u"лот",
        u"кг": u"кг",
    }
    return map[unit]


def convert_unit_from_smarttender_format(unit, field):
    map = {
        u"шт": {"code": "H87", "name": u"шт"},
        u"штуки": {"code": "H87", "name": u"штуки"},
        u"кг": {"code": "KGM", "name": u"кілограми"},
        u"умов.": {"code": "E48", "name": u"послуга"},
        u"м.кв.": {"code": "MTK", "name": u"метри квадратні"},
        u"упаков": {"code": "PK", "name": u"упаковка"},
        u"лот": {"code": "LO", "name": u"лот"},
        u"флак.": {"code": "VI", "name": u"Флакон"},
        u"%": {"code": "VI", "name": u"%"},
        u"пара": {"code": "PR", "name": u"пара"},
        u"літр": {"code": "LTR", "name": u"літр"},
        u"набір": {"code": "SET", "name": u"набір"},
        u"пачок": {"code": "NMP", "name": u"пачок"},
        u"метри": {"code": "MTR", "name": u"метри"},
        u"метри кубічні": {"code": "MTQ", "name": u"метри кубічні"},
        u"ящик": {"code": "BX", "name": u"ящик"},
        u"рейс": {"code": "E54", "name": u"рейс"},
        u"тони": {"code": "TNE", "name": u"тони"},
        u"кілометри": {"code": "KMT", "name": u"кілометри"},
        u"місяць": {"code": "MON", "name": u"місяць"},
        u"пачка": {"code": "RM", "name": u"пачка"},
        u"упаковка": {"code": "PK", "name": u"упаковка"},
        u"Упаковка": {"code": "PK", "name": u"упаковка"},
        u"гектар": {"code": "HAR", "name": u"гектар"},
        u"блок": {"code": "D64", "name": u"блок"},
    }
    return map[unit][field]


def convert_tender_status(value):
    map = {
        u"Прийом пропозицій": "active.tendering",
        u"Аукціон": "active.auction",
        u"Кваліфікація": "active.qualification",
        u"Оплачено, очікується підписання договору": "active.awarded",
        u"Торги не відбулися": "unsuccessful",
        u"Закупівля не відбулась": "unsuccessful",
        u"Завершено": "complete",
        u"Торги скасовано": "cancelled",
        u"Ваша раніше подана пропозиція у статусі «Недійсне». Необхідно підтвердження": "invalid",
        u"Очікує дискваліфікації першого учасника": "pending.waiting",
        u"Рішення скасовано": "cancelled",
        u"Очікує підтвердження протоколу": "pending.verification",
        u"Очікується оплата": "pending.payment",
        u"Переможець": "active",
        u"Переможе": "pending",
        u"Дискваліфікований": "unsuccessful",
        u"Період уточнень": "active.enquiries",
    }
    return map[value]


def convert_claim_status(value):
    map = {
        "Відхилена": 'cancelled'
    }
    return map[value]


def convert_datetime_to_smarttender_format(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%d.%m.%Y %H:%M")
    return date_string


def convert_datetime_to_kot_format(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%d.%m.%Y %H:%M:%S")
    return date_string


def convert_datetime_to_smarttender_form(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%d.%m.%Y")
    return date_string


def convert_date_offset_naive(s):
    dt = parse(s, parserinfo(True, False))
    return dt.strftime('%Y-%m-%d')


def convert_date(s):
    dt = parse(s, parserinfo(True, False))
    return dt.strftime('%Y-%m-%dT%H:%M:%S+03:00')



def adapt_data(tender_data):
    tender_data.data.procuringEntity[
        'name'] = u"ФОНД ГАРАНТУВАННЯ ВКЛАДІВ ФІЗИЧНИХ ОСІБ"
    tender_data.data.procuringEntity['identifier'][
        'legalName'] = u"ФОНД ГАРАНТУВАННЯ ВКЛАДІВ ФІЗИЧНИХ ОСІБ"
    tender_data.data.procuringEntity['identifier']['id'] = u"111111111111111"
    tender_data.data['items'][0].deliveryAddress.locality = u"Київ"
    for item in tender_data.data['items']:
        if item.unit['name'] == u"послуга":
            item.unit['name'] = u"усл."
        elif item.unit['name'] == u"метри квадратні":
            item.unit['name'] = u"м.кв."
        elif item.unit['name'] == u"упаковка":
            item.unit['name'] = u"упаков"
    for item in tender_data.data['items']:
        if item.deliveryAddress['region'] == u"місто Київ":
            item.deliveryAddress['region'] = u"Київська обл."
        elif item.deliveryAddress['region'] == u"Київська область":
            item.deliveryAddress['region'] = u"Київська обл."
        elif item.deliveryAddress['locality'] == u"Дніпро":
            item.deliveryAddress['locality'] = u"Кривий ріг"
    return tender_data


def get_question_data(id):
    return smarttender_munchify({'data': {'id': id}})


def map_to_smarttender_document_type(doctype):
    map = {
        u"x_presentation": u"Презентація",
        u"tenderNotice": u"Паспорт торгів",
        u"x_nda": u"Договір NDA",
        u"technicalSpecifications": u"Публічний паспорт активу",
        u"financial_documents": u"Цінова пропозиція",
        u"qualification_documents": u"Документи, що підтверджують кваліфікацію",
        u"eligibility_documents": u"Документи, що підтверджують відповідність",
    }
    return map[doctype]


def map_from_smarttender_document_type(doctype):
    map = {
        u"Презентація": u"x_presentation",
        u"Паспорт торгів": u"tenderNotice",
        u"Договір NDA": u"x_nda",
        u"Технические спецификации": u"technicalSpecifications",
        u"Порядок ознайомлення з майном/активом у кімнаті даних": u"x_dgfAssetFamiliarization",
        u"Посиланння на Публічний Паспорт Активу": u"x_dgfPublicAssetCertificate",
        u"Місце та форма прийому заявок на участь, банківські реквізити для зарахування гарантійних внесків":
            u"x_dgfPlatformLegalDetails",
        u"\u2015": u"none",
        u"Ілюстрація": u"illustration",
        u"Віртуальна кімната": u"vdr",
        u"Публічний паспорт активу": u"x_dgfPublicAssetCertificate"
    }
    return map[doctype]


def location_converter(value):
    if "cancellation" in value:
        response = "/cancellation/", "cancellation"
    elif "questions" in value:
        response = "/publichni-zakupivli-prozorro/", "questions"
    elif "proposal" in value:
        response = "/bid/edit/", "proposal"
    elif "awards" in value and "documents" in value:
        response = "/webparts/", "awards"
    elif "award_claims" in value:
        response = "/AppealNew/", "award_claims"
    elif "claims" in value:
        response = "/AppealNew/", "claims"
    elif "multiple_items" in value:
        response = "/webparts/", "multiple_items"
    else:
        response = "/publichni-zakupivli-prozorro/", "tender"
    return response


def download_file(url, download_path):
    response = urllib2.urlopen(url)
    file_content = response.read()
    open(download_path, 'a').close()
    f = open(download_path, 'w')
    f.write(file_content)
    f.close()


def normalize_index(first, second):
    if first == "-1":
        return "2"
    else:
        return str(int(first) + int(second))


def delete_spaces(value):
    return float(''.join(re.findall(r'\S', value)))


def get_attribute(value):
    if 'latitude' in value or 'longitude' in value:
        return True
    #elif 'features' in value and 'description' in value:
    #    return True
    else:
        return False


def synchronization(string):
    list = re.search(u'{"DateStart":"(?P<date_start>[\d\s\:\.]+?)",'
                     u'"DateEnd":"(?P<date_end>[\d\s\:\.]*?)",'
                     u'"WorkStatus":"(?P<work_status>[\w+]+?)",'
                     u'"Success":(?P<success>[\w+]+?)}', string)
    date_start = list.group('date_start')
    date_end = list.group('date_end')
    work_status = list.group('work_status')
    success = list.group('success')
    return date_start, date_end, work_status, success


def get_need_sync_status(value, name):
    fields = {
        'Period',
        'AddedTax',
        'currency',
        'amount',
        'tenderID',
        'classification',
        'unit.name',
        'unit.code',
        'contracts',
        'procuringEntity',
        'quantity',
        'deliveryDate',
        'suppliers',
        'deliveryLocation',
        'awards[0].documents[0]',
    }
    test_name = {
        'Відображення зміни статусу першої пропозиції після редагування інформації про тендер'
    }
    for item in fields:
        if item in value:
            return False
    if 'features[3].title' == value:
        return True
    elif ('status' in value) and (name in test_name):
        return True
    else:
        return True


def toJson(dict):
    return json.dumps(dict)

