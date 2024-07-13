from flask import Flask, request
import usb
import usb.core
import usb.backend.libusb1
import os
from PIL import Image
import io
import math
import numpy as np


app = Flask(__name__)

@app.route('/list', methods=['GET'])
def get_device_list():
    if os.getenv("LIBUSB_PATH", None) is not None:
        backend = usb.backend.libusb1.get_backend(find_library=lambda x: os.getenv("LIBUSB_PATH", ""))
        devices = usb.core.find(find_all=1, backend=backend)
    else:
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

def build_bitmap_print_tspl_cmd(x, y, img_width_px, img_height_px, canvas_width_mm, canvas_height_mm, image_bitmap):
    width_in_bytes = math.ceil(img_width_px / 8)
    commands_bytearray = bytearray()
    print(width_in_bytes)
    print(img_height_px)
    commands_list = [
        f"SIZE {canvas_width_mm} mm,{canvas_height_mm} mm\r\nCLS\r\n".encode(encoding="utf-8"),
        f"BITMAP {x},{y},{width_in_bytes},{img_height_px},1,".encode(encoding="utf-8"),
        image_bitmap,
        "\r\nPRINT 1\r\nEND\r\n".encode(encoding="utf-8"),
    ]
    # print(commands_list)
    for index, cmd in enumerate(commands_list):
        commands_bytearray.extend(cmd)
    return commands_bytearray 

def get_image_bytes(image_source):
    image = image_source
    if image.mode != '1':
        image = image.convert('1')
    imgData = np.array(image).flatten()
    print(np.packbits(imgData).shape)
    uint8list = np.packbits(imgData).tobytes()
    return uint8list

@app.route('/print/<int:vendor_id>/<int:product_id>', methods=['POST'])
def print_label(vendor_id, product_id):
    print_canvas_width_mm = request.args.get('print_canvas_width_mm', 70, type=int)
    print_canvas_height_mm = request.args.get('print_canvas_height_mm', 70, type=int)
    margin_top_px = request.args.get('margin_top_px', 0, type=int)
    margin_left_px = request.args.get('margin_left_px', 0, type=int)
    print_dpi = request.args.get('print_dpi', 203, type=int)
    max_width_px = int(round(print_canvas_width_mm * (print_dpi / 25.4)))
    max_height_px = int(round(print_canvas_height_mm * (print_dpi / 25.4)))

    if os.getenv("LIBUSB_PATH", None) is not None:
        backend = usb.backend.libusb1.get_backend(find_library=lambda x: os.getenv("LIBUSB_PATH", ""))
    # find our device
        dev = usb.core.find(idVendor=vendor_id, idProduct=product_id, backend=backend)
    else:
        dev = usb.core.find(idVendor=vendor_id, idProduct=product_id)
    # was it found?
    if dev is None:
        print("Device not found")
        return {"result": "error", "reason": "Device not found"}

    if dev.is_kernel_driver_active(0):
        try:
            dev.detach_kernel_driver(0)
        except usb.core.USBError as e:
            print("Could not detatch kernel driver from interface({0}): {1}".format(0, str(e)))
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
    assert ep is not None

    # get file from multipart/form-data
    uploaded_file = request.files['image']
    req_img_bytes = io.BytesIO()
    uploaded_file.save(req_img_bytes)
    image = Image.open(req_img_bytes)

    # resize image but keep ratio if it's bigger then max_width_px or max_height_px
    if image.width > max_width_px or image.height > max_height_px:
        image.thumbnail(size=(max_width_px, max_height_px))
    
    if image.width % 8 != 0 or image.height % 8 != 0:
        w_div_by_8 = image.width // 8
        h_div_by_8 = image.height // 8
        image.thumbnail(size=(w_div_by_8*8, h_div_by_8*8))

    monochrome_image_bytes = get_image_bytes(image)
    tspl_cmd = build_bitmap_print_tspl_cmd(
        margin_left_px, margin_top_px, 
        image.width, image.height, 
        print_canvas_width_mm, print_canvas_height_mm, 
        monochrome_image_bytes)
    ep.write(tspl_cmd)
    usb.util.dispose_resources(dev)
    return {"result": "success", "reason": "Data sent to the usb device"}

if __name__ == '__main__':
    app.run()