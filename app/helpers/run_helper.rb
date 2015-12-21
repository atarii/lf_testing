module RunHelper
  def td_download(href)
    <<-HTML.html_safe
    <td class="center">
      <a href="#{href}">
        <img width="20" height="20" title="Download this folder" src="/assets/download_folder.png">
      </a>
    </td>
    HTML
  end

  def td_delete(href)
    <<-HTML.html_safe
    <td class="center">
      <a class="delete" href="#{href}">
        <img width="20" height="20" title="Delete this folder" src="/assets/delete_folder.png">
      </a>
    </td>
    HTML
  end
end
