from flask import Flask, request
import usb

app = Flask(__name__)

@app.route('/list', methods=['GET'])
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

@app.route('/write_usb/<int:vendor_id>/<int:product_id>', methods=['POST'])
def write_usb(vendor_id, product_id):
    file = request.files['file']
    # find our device
    dev = usb.core.find(idVendor=vendor_id, idProduct=product_id)

    # was it found?
    if dev is None:
        return {"result": "error", "reason": "Device not found"}

    # set the active configuration. With no arguments, the first
    # configuration will be the active one
    dev.set_configuration()

    # get an endpoint instance
    cfg = dev.get_active_configuration()
    intf = cfg[(0,0)]

    ep = usb.util.find_descriptor(
    intf,
    # match the first OUT endpoint
    custom_match = \
    lambda e: \
        usb.util.endpoint_direction(e.bEndpointAddress) == \
        usb.util.ENDPOINT_OUT)
    bytes_to_write = request.get_data()
    ep.write(bytes_to_write)
    return {"result": "success", "reason": "Data sent to the usb device"}

if __name__ == '__main__':
    app.run()