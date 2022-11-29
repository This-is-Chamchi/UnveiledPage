using UnityEngine;
using UnityEngine.SceneManagement;

public class DeadState : IState {
    private float m_WaitNextScene = 0.0f;
    private GameObject _Hansel;
    private GameObject _Gretel;
    private GameObject _Anna;

    public override void OnStateEnter(PlayerController player)  {
        player.rigid.velocity = Vector3.zero;
        player.ani.SetTrigger("Death");
        player.invinBool = true;
        player.input.SetInputAction(false);
        _Hansel = GameObject.FindWithTag("Boss");
        _Gretel = GameObject.FindWithTag("Gretel");
        _Anna = GameObject.FindWithTag("Anna");

        if (_Hansel != null) _Hansel.gameObject.SetActive(false);            
        if (_Gretel != null) _Gretel.gameObject.SetActive(false);
        if (_Anna != null) _Anna.gameObject.SetActive(false);
    }
    public override void OnStateExcute(PlayerController player) {
        m_WaitNextScene += Time.deltaTime;
        if (m_WaitNextScene >= 3.0f)    SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        return;
    }

    public override void OnStateExit(PlayerController player)   {
        return;
    }
}
