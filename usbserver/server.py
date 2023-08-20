from flask import Flask
import usb

app = Flask(__name__)

@app.route('/')
def get_device_list():
    devices = usb.core.find(find_all=1)
    device_list_dict = []
    for device in devices:
        device_list_dict.append({
            'vendorId': device.idVendor,
            'productId': device.idProduct,
            'manufacturerName': usb.util.get_string(device, device.iManufacturer),
            'productName': usb.util.get_string(device, device.iProduct),
        })
    return device_list_dict

if __name__ == '__main__':
    app.run()