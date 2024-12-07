import 'package:flutter/material.dart';
import 'package:satelite_peru_gps/presentation/components/constant/app_text_style.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color disabledColor; // Color para el estado deshabilitado
  final Function()? press;
  final bool isLoading;
  final bool isDisabled; // Propiedad para el estado deshabilitado

  const RoundedButton({
    Key? key,
    required this.text,
    required this.color,
    // this.disabledColor = Colors.grey, // Color predeterminado para deshabilitado
    this.disabledColor = const Color(0xffABABAB),
    required this.press,
    this.isLoading = false,
    this.isDisabled = false, // Valor predeterminado para habilitado
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            8), // Menor radio de borde para borde menos pronunciado
        child: TextButton(
          onPressed: isDisabled || isLoading ? null : press,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            backgroundColor: isDisabled ? disabledColor : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8), // Menor radio de borde para borde menos pronunciado
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: AppTextStyle.MIDDLE_BUTTON_TEXT_BOLD.copyWith(
                    color:
                        // isDisabled
                        //     ? Colors.black.withOpacity(0.6)
                        //     :
                        Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
