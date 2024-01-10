import json
import asyncio
import boto3
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, MessageHandler, filters

ssm_client = boto3.client('ssm')


ssm_parameters = ssm_client.get_parameters(Names=['/testbot/prod/ai_bot/telegram_token'], WithDecryption=True)
secrets = {}

for parameter in ssm_parameters.get('Parameters'):
    name = parameter.get('Name')
    value = parameter.get('Value')
    secrets[name] = value


application = ApplicationBuilder().token(secrets['telegram_token']).build()


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=update.effective_chat.id, text="I'm a bot, please talk to me!")


async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=update.effective_chat.id, text=update.message.text)


def lambda_handler(event, context):
    return asyncio.get_event_loop().run_until_complete(main(event, context))


async def main(event, context):
    start_handler = CommandHandler('start', start)
    application.add_handler(start_handler)

    echo_handler = MessageHandler(filters.TEXT & (~filters.COMMAND), echo)
    application.add_handler(echo_handler)

    try:
        await application.initialize()
        await application.process_update(
            Update.de_json(data=json.loads(event["body"]), bot=application.bot)
        )
        return {
            'statusCode': 200,
            'body': 'Success'
        }

    except Exception as exc:
        print(exc)
        return {
            'statusCode': 500,
            'body': 'Failure'
        }

