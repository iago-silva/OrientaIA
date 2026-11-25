class DemoDocument
  def self.pdf(title, body)
    lines = [ title, "OrientaAI - Documento demonstrativo", "", *body.split("\n").flat_map { |line| line.scan(/.{1,85}(?:\s|$)/).presence || [ line ] } ].first(40)
    stream = +"BT /F1 11 Tf 50 790 Td 16 TL\n"
    lines.each do |line|
      safe = I18n.transliterate(line).gsub(/[^\x20-\x7E]/, "").gsub(/([\\()])/) { |char| "\\#{char}" }
      stream << "(#{safe}) Tj T*\n"
    end
    stream << "ET\n"
    objects = [ "<< /Type /Catalog /Pages 2 0 R >>", "<< /Type /Pages /Kids [3 0 R] /Count 1 >>", "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>", "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>", "<< /Length #{stream.bytesize} >>\nstream\n#{stream}endstream" ]
    pdf = +"%PDF-1.4\n"
    offsets = [ 0 ]
    objects.each_with_index { |object, i| offsets << pdf.bytesize; pdf << "#{i + 1} 0 obj\n#{object}\nendobj\n" }
    start = pdf.bytesize
    pdf << "xref\n0 6\n0000000000 65535 f \n"
    offsets.drop(1).each { |offset| pdf << "%010d 00000 n \n" % offset }
    pdf << "trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n#{start}\n%%EOF\n"
    pdf
  end
end
