import os
import time
import random
from PIL import Image, ImageTk
from math import sqrt
import tkinter as tk
from tkinter import ttk
from tkinter import filedialog as fd
from tkinter.messagebox import showinfo



#Function for pyinstaller to correctly use the .ico file
def resource_path(relative_path):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

window = tk.Tk()
window.title("Milk filter!")
widthWindow= window.winfo_screenwidth()               
heightWindow= window.winfo_screenheight()               
window.geometry("%dx%d" % (widthWindow, heightWindow))
window.state('normal')

#iconPath = resource_path("icon.ico")

#iconPhoto = ImageTk.PhotoImage(file = iconPath)
#window.iconphoto(False, iconPhoto)


#Add scrollbar vertically
main_frame = tk.Frame(window)

main_frame.pack(fill=tk.BOTH,expand=1)

my_canvas = tk.Canvas(main_frame)
my_canvas.pack(side=tk.LEFT,fill=tk.BOTH,expand=1)

my_scrollbar = ttk.Scrollbar(main_frame,orient=tk.VERTICAL,command=my_canvas.yview)
my_scrollbar.pack(side=tk.RIGHT,fill=tk.Y)

my_canvas.configure(yscrollcommand=my_scrollbar.set)
my_canvas.bind('<Configure>',lambda e:my_canvas.configure(scrollregion=my_canvas.bbox("all")))

second_frame = tk.Frame(my_canvas)


# Configure grid in `second_frame` for vertical centering
second_frame.grid_rowconfigure(0, weight=1)  # Top spacer
second_frame.grid_rowconfigure(1, weight=0)  # Frame 1
second_frame.grid_rowconfigure(2, weight=0)  # Frame 2
second_frame.grid_rowconfigure(3, weight=0)  # Frame 3
second_frame.grid_rowconfigure(4, weight=1)  # Bottom spacer

second_frame.grid_columnconfigure(0, weight=1)  # Center column

my_canvas.create_window((0,0), window=second_frame,anchor="nw")

# Function to check if scrolling is active
def is_scroll_active():
    scroll_region = my_canvas.cget('scrollregion')
    if not scroll_region:  # If no scrollregion is defined, scrolling is inactive
        return False
    x1, y1, x2, y2 = map(int, scroll_region.split())
    canvas_height = my_canvas.winfo_height()
    return (y2 - y1) > canvas_height  # Active if content height > canvas height

# Function to handle mouse wheel scrolling
def _on_mouse_wheel(event):
    if is_scroll_active():  # Only scroll if the scrollbar is active
        my_canvas.yview_scroll(-1 * int((event.delta / 120)), "units")

my_canvas.bind_all("<MouseWheel>", _on_mouse_wheel)

frame_1 = ttk.Frame(second_frame)
frame_2 = ttk.Frame(second_frame)
frame_3 = ttk.Frame(second_frame)

# Configure columns for centering
frame_2.grid_columnconfigure(0, weight=1)  # Left column
frame_2.grid_columnconfigure(1, weight=1)  # Center column
frame_2.grid_columnconfigure(2, weight=1)  # Right column


def showImgViewer(imgVw):
    imgVw.show()

def show_image(imagShow):
    global imagShowD
    # Create a new Toplevel window
    viewer = tk.Toplevel()
    viewer.title("Image Viewer")
    viewer.iconphoto(False, iconPhoto)

    canvasViewer = tk.Canvas(viewer)
    canvasViewer.pack(fill=tk.BOTH,expand=1)

    imagShowD = imagShow.resize((int(widthWindow/1.5), int(heightWindow/1.5)), Image.Resampling.LANCZOS)
    photo = ImageTk.PhotoImage(imagShowD)
    label = tk.Label(canvasViewer, image=photo)
    label.image = photo
    label.pack(fill=tk.BOTH,expand=1)

    show_button = ttk.Button(canvasViewer,text='See file in image viewer',command=lambda:showImgViewer(imagShow))

    show_button.pack(expand=True)

    # Detect when the Toplevel window is closed
    def on_close():
        viewer.destroy()

    viewer.protocol("WM_DELETE_WINDOW", on_close)


def save_image(imageSave):
    fileSave = fd.asksaveasfile(defaultextension=".png",filetypes=[(".png",".png"),(".jpg",".jpg"),(".jpeg",".jpeg")])
    imageSave.save(fileSave.name)

def apply_filter(filename):
        global savedButton
        global save_button
        def probably(chance):
            return random.random() < chance

        if eff.get() == 1:
            punt = 70
        else:
            punt = 100

        imag = Image.open(filename)
      #Convert the image te RGB if it is a .gif for example
        imag = imag.convert ('RGB')
      #Get RGB

      #lower quality first:
        if comp.get() == 1:
            imag.save("temp.jpg", quality=100-slider_int.get())
            imag = Image.open("temp.jpg")

        width,height = imag.size

      #This is where most of the filter is applied. It checks for each pixel and depending on its
      #brightness level, it assigns one of the characteristic colours of the game.
        if milk.get() == 1:
            for x in range(width):
                for y in range(height):
                    pixelRGB = imag.getpixel((x,y))
                    R,G,B = pixelRGB
                    brightness = sum([R,G,B])/3
                    if brightness <= 25:
                        imag.putpixel((x,y),(0,0,0,255))
                    if brightness > 25 and brightness <= 70:
                        if probably(punt/100):
                            imag.putpixel((x,y),(0,0,0,255))
                        else:
                            imag.putpixel((x,y),(102,0,31,255))
                    if brightness > 70 and brightness < 120:
                        if probably(punt/100):
                            imag.putpixel((x,y),(102,0,31,255))
                        else:
                            imag.putpixel((x,y),(0,0,0,255))
                    if brightness >= 120 and brightness < 200:
                            imag.putpixel((x,y),(102,0,31,255))
                    if brightness >= 200 and brightness < 230:
                        if probably(punt/100):
                            imag.putpixel((x,y),(137,0,146,255))
                        else:
                            imag.putpixel((x,y),(102,0,31,255))
                    if brightness >= 230:
                        imag.putpixel((x,y),(137,0,146,255))
        else:
            for x in range(width):
                for y in range(height):
                    pixelRGB = imag.getpixel((x,y))
                    R,G,B = pixelRGB
                    brightness = sum([R,G,B])/3
                    if brightness <= 25:
                        imag.putpixel((x,y),(0,0,0,255))
                    if brightness > 25 and brightness <= 70:
                        if probably(punt/100):
                            imag.putpixel((x,y),(0,0,0,255))
                        else:
                            imag.putpixel((x,y),(92,36,60,255))
                    if brightness > 70 and brightness < 90:
                        if probably(punt/100):
                            imag.putpixel((x,y),(92,36,60,255))
                        else:
                            imag.putpixel((x,y),(0,0,0,255))
                    if brightness >= 90 and brightness < 150:
                            imag.putpixel((x,y),(92,36,60,255))
                    if brightness >= 150 and brightness < 200:
                        if probably(punt/100):
                            imag.putpixel((x,y),(203,43,43,255))
                        else:
                            imag.putpixel((x,y),(92,36,60,255))
                    if brightness >= 200:
                        imag.putpixel((x,y),(203,43,43,255))

        imagResize = imag.resize((int(widthWindow/2.2), int(heightWindow/2.2)), Image.Resampling.LANCZOS)
        imgFilter = ImageTk.PhotoImage(imagResize)
        applied.config(image=imgFilter)
        applied.image = imgFilter
        window.update_idletasks()
        my_canvas.configure(scrollregion=my_canvas.bbox("all"))
        if savedButton == False:
            save_button = ttk.Button(frame_3,text='Save image',command=lambda: save_image(imag))
            save_button.pack(expand=True,pady=5)
            savedButton = True
            window.update_idletasks()
            my_canvas.configure(scrollregion=my_canvas.bbox("all"))
        else:
            save_button.config(command=lambda: save_image(imag))
        show_image(imag)

def on_value_change(value):
    slider_number_label.configure(text=str(int(float(value))))

def slider_display():
    if(comp.get()==1):
        slider_label.pack()
        slider.pack()
        slider_number_label.pack()
        slider.configure(command=on_value_change)
        window.update_idletasks()
        my_canvas.configure(scrollregion=my_canvas.bbox("all"))
    else:
        slider_label.pack_forget()
        slider.pack_forget()
        slider_number_label.pack_forget()
        window.update_idletasks()
        my_canvas.configure(scrollregion=my_canvas.bbox("all"))

def select_file():
    global button_created
    global apply_button
    filetypes = (
                        ('Image files (.png,.jpg,.jpeg)', '*.png'),
                        ('Image files (.png,.jpg,.jpeg)','*.jpg'),
                        ('Image files (.png,.jpg,.jpeg)','*.jpeg')
                )

    filename = fd.askopenfilename(title='Open a file',initialdir='.',filetypes=filetypes)

    img = Image.open(filename)
    resized_img = img.resize((int(widthWindow/2.2), int(heightWindow/2.2)), Image.Resampling.LANCZOS)
    imgTk = ImageTk.PhotoImage(resized_img)
    display.config(image=imgTk)
    display.image = imgTk
    window.update_idletasks()
    my_canvas.configure(scrollregion=my_canvas.bbox("all"))
    
    if(button_created == False):     
        compression = tk.Checkbutton(frame_3, text='Compression?', variable = comp,onvalue=1,offvalue=0,command=slider_display)
        compression.pack()
        effect = tk.Checkbutton(frame_3, text='Pointillism effect?', variable = eff,onvalue=1,offvalue=0)
        effect.pack()
        R1 = tk.Radiobutton(frame_3, text="Milk1 effect", variable=milk, value=1)
        R1.pack()
        R1.select()
        R2 = tk.Radiobutton(frame_3, text="Milk2 effect", variable=milk, value=2)
        R2.pack()

        apply_button = ttk.Button(frame_3,text='Apply filter',command=lambda: apply_filter(filename))
        apply_button.pack(expand=True)
        window.update_idletasks()
        my_canvas.configure(scrollregion=my_canvas.bbox("all"))
        button_created = True
    else:
        apply_button.config(command=lambda: apply_filter(filename))


open_button = ttk.Button(frame_1,text='Open a File',command=select_file)

open_button.pack(expand=True)

button_created = False
savedButton = False

apply_button = ttk.Button(frame_3,text='Apply test',command=lambda: apply_filter(filename))
save_button = ttk.Button(frame_3,text='Save image',command=lambda: save_image(imag))

slider_label = tk.Label(frame_3,text="Level of compression (from 0 best quality to 100 worst quality): ")
slider_label.pack()
slider_label.pack_forget()

slider_int = tk.IntVar(value = 0)
slider = ttk.Scale(frame_3, variable = slider_int,from_=0,to=100)
slider.pack()
slider.pack_forget()

slider_number_label = tk.Label(frame_3,text="0")
slider_number_label.pack()
slider_number_label.pack_forget()

comp = tk.IntVar()
eff = tk.IntVar()

milk = tk.IntVar()

rect = Image.new(mode='RGB', size=(int(widthWindow/2.2), int(heightWindow/2.2)),color=(203, 203, 203))
rectTk = ImageTk.PhotoImage(rect)

display = tk.Label(frame_2)
display.pack(side = tk.LEFT)

display.config(image=rectTk)
display.image = rectTk

applied = tk.Label(frame_2)
applied.pack(side = tk.LEFT)
applied.config(image=rectTk)
applied.image = rectTk

window.update_idletasks()
my_canvas.configure(scrollregion=my_canvas.bbox("all"))


frame_1.grid(row=1,column=0, pady=5)
frame_2.grid(row=2,column=0, pady=5)
frame_3.grid(row=3,column=0, pady=5)

second_frame.pack(fill=tk.BOTH,expand=1)


window.mainloop()