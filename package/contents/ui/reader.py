#-*- coding: UTF-8 -*-
import requests
import io
import time
from sys import argv
script, url, meta = argv

URL = url
METADATA = meta
def main():
    headers = {
        'Icy-MetaData': '1'
    }

    while True:
        try:
            # Выполняем запрос к радио-потоку
            response = requests.get(URL, headers=headers, stream=True)

            if response.status_code != 200:
              #  print(f"Failed to connect to stream. Status code: {response.status_code}")
                time.sleep(10)  # Пауза перед повторным запуском
                continue

            # Получаем заголовок icy-metaint из ответа
            icy_metaint = int(response.headers.get('icy-metaint', 0))

            if icy_metaint == 0:
                #print("Icy-Metaint header not found or metaint is 0.")
                time.sleep(10)  # Пауза перед повторным запуском
                continue

            #print(f"Icy-Metaint: {icy_metaint}")

            # Создаем буфер для чтения данных
            buffer = io.BytesIO()
            found_stream_title = False

            try:
                for chunk in response.iter_content(chunk_size=1024):
                    buffer.write(chunk)

                    # Проверяем, есть ли достаточно данных в буфере для обработки метаданных
                    while buffer.tell() >= icy_metaint:
                        buffer.seek(icy_metaint)
                        metadata = buffer.read(4096)

                        # Распознаем и извлекаем StreamTitle из метаданных
                        while b'StreamTitle=' in metadata:
                            title_start_index = metadata.index(b'StreamTitle=') + len(b'StreamTitle=')
                            url_start_index = metadata.index(b'StreamUrl=') + len(b'StreamUrl=')
                            title_end_index = metadata.find(b';', title_start_index)
                            url_end_index = metadata.find(b';', url_start_index)

                            if title_end_index == -1:
                                title_end_index = len(metadata)
                            stream_title = metadata[title_start_index:title_end_index].decode('utf-8')
                            if stream_title.startswith("'") and stream_title.endswith("'"):
                                stream_title = stream_title[1:-1]
                            #print(stream_title)

                            if url_end_index == -1:
                                url_end_index = len(metadata)
                            stream_url = metadata[url_start_index:url_end_index].decode('utf-8')
                            if stream_url.startswith("'") and stream_url.endswith("'"):
                                stream_url = stream_url[1:-1]
                            #print(stream_url)

                            stream_metadata = stream_title + "::" + stream_url
                            if stream_metadata != METADATA:
                                print(stream_metadata)

                            # Устанавливаем флаг, что данные были успешно получены
                            found_stream_title = True

                            # Удаляем обработанные метаданные из буфера
                            metadata = metadata[end_index:]
                            if not metadata:
                                break

                        # Сбрасываем буфер для обработки следующего пакета данных
                        buffer = io.BytesIO(metadata)

                    # Если метаданные уже были найдены, прекращаем чтение и закрываем соединение
                    if found_stream_title:
                        break

            except KeyboardInterrupt:
                print("Interrupted by user.")
                break

        except (requests.RequestException, KeyboardInterrupt) as e:
            print(f"Error occurred: {e}")
            time.sleep(10)  # Пауза перед переподключением
        finally:
            response.close()
            # Если данные были успешно получены, выходим из цикла
            if found_stream_title:
                break
main()
#if __name__ == "__main__":
#    # Укажите URL радио-потока
#    radio_stream_url = url
#    get_stream_title(radio_stream_url)




